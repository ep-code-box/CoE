**Purpose**
- Provide a precise, migration-backed design to filter Tools and LangFlow Flows by `group_name` alongside `context`, with unambiguous matching and safe fallbacks.

**Goals**
- Accurate per-request filtering when `group_name` is present.
- Strong backward compatibility: public tools/flows continue to work when `group_name` is absent.
- Keep LLM-first argument extraction and natural output intact.
- Prefer a structured DB schema; keep a temporary compatibility layer for zero-downtime migration.

**Non-Goals**
- Authorization/entitlement is out of scope. Group filtering is UX scoping, not access control.

**API Contract**
- Request schema includes `group_name: Optional[str]` in `OpenAIChatRequest`.
- Behavior: With `group_name`, candidates are filtered to the caller’s group and to public entries; without it, only public entries apply.
- Input validation: `group_name` is normalized to lowercase and must match `^[a-z0-9]([a-z0-9-_]{0,62}[a-z0-9])?$`.

**Data Model (Recommended)**
- LangFlow mappings
  - Table: `langflow_tool_mappings(flow_id, context, group_name NULLABLE, description, …)`
  - Semantics: `group_name = NULL` means public (all groups). Non-NULL means restricted to that group only.
  - Indexes: `idx_ltm_flow_ctx_grp (flow_id, context, group_name)`, plus `idx_ltm_ctx_grp (context, group_name)`.
  - Constraint: keep `(flow_id, context, group_name)` unique. For MySQL compatibility, either (a) add an application-level guard when inserting rows, or (b) introduce a generated column that materializes `COALESCE(group_name,'')` and apply a unique index to that field if the target MySQL version supports it.
- Python tools (module metadata)
  - Module-level optional `allowed_groups: List[str]` for all tools in a map.
  - Optional `allowed_groups_by_tool: Dict[str, List[str]]` for per-tool granularity.
  - If neither is present, the tool is public.
- Optional: Group registry
  - Table: `groups(name PRIMARY KEY, display_name, is_active)` to validate/curate group names.
  - Not required for MVP; recommended if group set is curated.

**Matching Rules**
- Python tools
  - If `group_name` is absent: include only public tools (no `allowed_groups*` declared) or treat absence as public. Tools with explicit `allowed_groups*` are excluded.
  - If `group_name` is present: include tools where either
    - `allowed_groups_by_tool[name]` contains the group, or
    - `allowed_groups` (module-level) contains the group, or
    - No `allowed_groups*` is defined (public).
  - If any `allowed_groups*` is defined and the group does not match, the tool is excluded.
- LangFlow flows
  - If `group_name` is absent: allow a flow if a mapping row exists with `(flow_id, context, group_name IS NULL)`.
  - If `group_name` is present: allow a flow if a mapping row exists with `(flow_id, context, group_name = :group)` OR `(flow_id, context, group_name IS NULL)`.
  - When both variants exist, treat the `(context, group_name)` mapping as higher priority than the public `(context, NULL)` row during tool selection.
  - Public rows (NULL `group_name`) remain eligible so callers without a group still see defaults.

**Fallback Policy (Strict-Safe)**
- If `group_name` present and filtering yields zero candidates:
  - Do not “ignore restrictions”.
  - Python tools: consider only public tools (no `allowed_groups*`).
  - LangFlow flows: consider only public rows (`group_name IS NULL`).
  - If still empty, skip proactive auto-routing and proceed with normal LLM tool-calling.
- If `group_name` absent: use public candidates only. No hidden group-restricted candidates are surfaced.

**Control Flags**
- `ENABLE_GROUP_FILTERING` (env, default: true)
  - true (default): apply the rules above.
  - false: ignore group filters entirely (full backward compatibility). Use for quick rollback or legacy debugging.

**Normalization & Validation**
- Normalize `group_name` to lowercase and trim whitespace at request ingress.
- Reject values containing `:` or spaces. Length 1–64. Regex as above.
- If a registry table exists, reject unknown/inactive groups with a 400; otherwise treat unknown groups as having no matches (public-only fallback).

**Logging & Observability**
- Structured log fields on candidate collection: `context`, `group_name`, counts before/after, and skip reasons.
- Persist `group_name` on API logs and messages if desired:
  - Optional Alembic: add `group_name` to `api_logs` and/or store in `tool_metadata` of `chat_messages`.
- Add metrics counters: `tools.candidates.total`, `tools.candidates.filtered`, `flows.candidates.total`, `flows.candidates.filtered` with labels `context`, `group`.

**Migration Plan (Structured First-Class)**
- Phase 0: Ensure code behaves with filtering enabled by default. Provide a rollback flag (`ENABLE_GROUP_FILTERING=false`).
- Phase 1: Alembic migration
  - Add `group_name` (NULLABLE) to `langflow_tool_mappings`.
  - Add indexes/constraints listed above.
  - Optional: create `groups` table; seed known groups.
- Phase 2: Data backfill/compat
  - If composite keys like `context:group` exist in `context`, split into `(context, group_name)` rows.
  - Keep a temporary compatibility read: accept composite context rows for a deprecation window.
- Phase 2.5: Extend write paths
  - Update `FlowCreate`/`FlowUpdate` schemas (and the `/flows/save` handler) to accept `(context, allowed_groups)` pairs so authors can seed group-specific mappings via API.
  - Add admin helpers or CLI scripts to upsert `(context, group_name)` rows directly when needed.
- Phase 3: Switch on `ENABLE_GROUP_FILTERING=true` in dev/staging, validate logs and counts.
- Phase 4: Remove composite key support and clean up data; enable in production.

**Rollout Steps**
- Implement feature flag + filtering in dispatcher and flow allow-check.
- Add `allowed_groups`/`allowed_groups_by_tool` to selected tool maps as needed.
- Seed public and group-specific LangFlow mapping rows; backfill from composite if present.
- Update LangFlow CRUD APIs so operators can manage `group_name` assignments without touching the DB manually.
- Validate in dev/staging; monitor candidate counts and fallback rates; then enable in production.

**Code Touch Points**
- Dispatcher APIs
  - `get_available_tools_for_context(context: str, group_name: Optional[str], enable_group_filtering: bool) -> (schemas, functions)`
  - `_flow_allowed_in_context(db, flow, context: Optional[str], group_name: Optional[str], enable_group_filtering: bool) -> bool`
- Callers pass-through `group_name` and flag
  - `api/chat_api.py` when loading server tool schemas.
  - `core/agent_nodes.py` in dispatcher node.
- Map metadata (optional per-tool granularity)
  - Support `allowed_groups` and `allowed_groups_by_tool` in `*_map.py`.
- LangFlow execution helpers
  - `services/tool_dispatcher.find_langflow_tool`, `tools/langflow_tool.py` (`list_langflows_run`, `execute_langflow_run`), and auto-routing helpers (`maybe_execute_best_tool*`) must apply the same `(context, group_name)` logic when fetching flows.

**Compatibility & Deprecation**
- With flag off: behavior identical to current system.
- During migration: code accepts both structured rows and legacy composite `context:group` rows.
- After deprecation: only structured `(context, group_name)` is read; composite keys should be removed.

**Testing Plan**
- Unit
  - Map loader: module-level vs per-tool `allowed_groups*` precedence; public vs restricted behavior.
  - Flow allow-check: `(context, NULL)` and `(context, group)` matching.
  - Normalization: invalid or mixed-case `group_name` handling.
- Integration
  - `group_name` present vs absent yields different candidates as expected.
  - Zero-match with strict fallback to public only.
  - Flag off restores full visibility.
- E2E (curl)
  - Same prompt with and without `group_name`; verify tool/flow differences and natural responses.

**Open Questions**
- Do we need per-group ranking boosts on top of filtering?
- Should we adopt a formal group registry and UI to manage groups?
- Do we surface the applied group filter in API responses for transparency (e.g., headers)?

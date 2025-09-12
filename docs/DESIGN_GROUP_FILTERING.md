**Purpose**
- Define a safe, incremental design to filter Tools and LangFlow Flows by `group_name` in addition to `context`, without breaking existing behavior.

**Goals**
- Optional per-request filtering when `group_name` is present.
- Preserve full backward compatibility when `group_name` is absent.
- Keep LLM-first argument extraction and natural output intact.
- Minimize code churn; allow a no‑migration path for LangFlow mapping.

**Non-Goals**
- Authorization/entitlement is out of scope. Group filtering here is a UX scoping aid, not an access control mechanism.

**API Contract**
- Request schema already includes `group_name` (optional) in `OpenAIChatRequest`.
- Behavior: If `group_name` is provided, the candidate Tool/Flow set is further filtered; if none remain, fall back to context-only or normal LLM behavior.

**Design Overview**
- Filtering is applied at two collection points:
  - Python Tools: While loading context-scoped tool schemas/functions.
  - LangFlow Flows: While validating if a flow is allowed for the current context.
- Execution, formatting, and LLM-based argument generation remain unchanged.

**Python Tools Filtering**
- Each `*_map.py` MAY declare `allowed_groups: List[str]` (optional).
  - When absent → tool is visible to all groups (backward compatible).
  - When present → tool is visible only if `group_name` ∈ `allowed_groups`.
- No changes to `*_tool.py` contracts.

**LangFlow Flows Filtering**
- Two implementation options:
  - Option A (No migration): Use composite context keys in `langflow_tool_mappings.context`.
    - Accept both `context` and `"{context}:{group_name}"` when checking allow-list.
    - To restrict a flow to a group, add a row with `context = "aider:dev-team"`.
  - Option B (Migration): Add a nullable `group_name` column to `langflow_tool_mappings`.
    - Matching rule: (flow_id, context, group_name) with `group_name` NULL = all groups.
    - Requires Alembic migration and CRUD updates.
- Recommendation: Start with Option A for zero-migration rollout, then consider Option B later if needed.

**Control Flags**
- `ENABLE_GROUP_FILTERING` (env, default: true)
  - true: apply group filtering when `group_name` present.
  - false: ignore group filters entirely (fast rollback switch).

**Failure and Fallback Behavior**
- If `group_name` is provided but no candidates match:
  - Fallback 1: Use context-only candidates (ignore group).
  - Fallback 2: Skip proactive auto-routing and let LLM proceed with its normal tool calls.
- All fallbacks produce natural, concise responses.

**Logging & Observability**
- Log the effective filtering: `context`, `group_name`, candidate counts (before/after), and reason for skips.
- Include `group_name` tag/field in auto-routing logs and API call logs for debugging.

**Testing Plan**
- Unit
  - Map loader filters tools based on `allowed_groups`.
  - Flow allow-check accepts `context` and `context:group`.
- Integration
  - With `group_name`, only expected tools/flows appear; without it, all context tools/flows appear.
  - Fallbacks when zero matches.
- E2E (curl)
  - Chat with `group_name` present vs absent; verify different candidates/answers.

**Migration Plan**
- Phase 1 (No migration)
  - Adopt composite context pattern for LangFlow mappings (e.g., `aider:dev-team`).
  - Add `allowed_groups` to Tool maps where restriction is required.
- Phase 2 (Optional migration)
  - Introduce `group_name` column to `langflow_tool_mappings` with Alembic.
  - Backfill composite keys to structured fields; keep a view or compatibility layer if needed.

**Rollout Steps**
- Step 1: Implement feature flag + filtering logic behind it.
- Step 2: Add `allowed_groups` to selected Tool maps; add a few composite LangFlow mapping rows.
- Step 3: Validate in dev with sample `group_name`s (e.g., `dev-team`, `alpha`).
- Step 4: Enable in staging; monitor logs for candidate counts and fallbacks.
- Step 5: Enable in production.

**Code Touch Points (Minimal)**
- Map loader: `services/tool_dispatcher.get_available_tools_for_context(context, group_name)`
  - Read optional `allowed_groups` from map modules.
- Flow allow-check: `_flow_allowed_in_context(db, flow, context, group_name)`
  - Accept `context` and `"context:group_name"` as allowed keys (Option A).
- Call sites pass-through `group_name`:
  - `api/chat_api.py` when loading server tool schemas.
  - `core/agent_nodes.py` in dispatcher node.

**Compatibility & Safety**
- No changes required to existing Tool/Flow definitions to retain current behavior.
- Group filtering only narrows candidates when `group_name` is provided and filtering is enabled.
- Easy rollback via `ENABLE_GROUP_FILTERING=false`.

**Open Questions**
- Do we need per-group prioritization (e.g., ranking boosts) in addition to filtering?
- Should `group_name` be validated against a directory/list to avoid typos?
- Do we want API responses to surface which group filter was applied (for transparency)?


/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.0.2-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: coe_db
-- ------------------------------------------------------
-- Server version	12.0.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alembic_version_backend`
--

DROP TABLE IF EXISTS `alembic_version_backend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version_backend` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alembic_version_rag`
--

DROP TABLE IF EXISTS `alembic_version_rag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version_rag` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analysis_requests`
--

DROP TABLE IF EXISTS `analysis_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `analysis_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_id` varchar(36) NOT NULL,
  `status` enum('PENDING','RUNNING','COMPLETED','FAILED') DEFAULT NULL,
  `repositories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `include_ast` tinyint(1) DEFAULT NULL,
  `include_tech_spec` tinyint(1) DEFAULT NULL,
  `include_correlation` tinyint(1) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_analysis_requests_analysis_id` (`analysis_id`),
  KEY `ix_analysis_requests_group_name` (`group_name`),
  KEY `ix_analysis_requests_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_logs`
--

DROP TABLE IF EXISTS `api_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) DEFAULT NULL,
  `endpoint` varchar(255) NOT NULL,
  `method` enum('GET','POST','PUT','DELETE','PATCH') NOT NULL,
  `request_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`request_data`)),
  `response_status` int(11) DEFAULT NULL,
  `response_time_ms` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `selected_tool` varchar(100) DEFAULT NULL,
  `tool_execution_time_ms` int(11) DEFAULT NULL,
  `tool_success` tinyint(1) DEFAULT NULL,
  `tool_error_message` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_api_logs_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ast_nodes`
--

DROP TABLE IF EXISTS `ast_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ast_nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_file_id` int(11) NOT NULL,
  `node_type` varchar(100) NOT NULL,
  `node_name` varchar(255) DEFAULT NULL,
  `line_start` int(11) DEFAULT NULL,
  `line_end` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `node_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`node_metadata`)),
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `code_file_id` (`code_file_id`),
  KEY `parent_id` (`parent_id`),
  KEY `ix_ast_nodes_id` (`id`),
  CONSTRAINT `ast_nodes_ibfk_1` FOREIGN KEY (`code_file_id`) REFERENCES `code_files` (`id`),
  CONSTRAINT `ast_nodes_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `ast_nodes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL,
  `content` longtext NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `turn_number` int(11) NOT NULL,
  `selected_tool` varchar(100) DEFAULT NULL,
  `tool_execution_time_ms` int(11) DEFAULT NULL,
  `tool_success` tinyint(1) DEFAULT NULL,
  `tool_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tool_metadata`)),
  PRIMARY KEY (`id`),
  KEY `ix_chat_messages_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `code_files`
--

DROP TABLE IF EXISTS `code_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `code_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repository_analysis_id` int(11) NOT NULL,
  `file_path` varchar(1000) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int(11) DEFAULT NULL,
  `language` varchar(50) DEFAULT NULL,
  `complexity_score` decimal(5,2) DEFAULT NULL,
  `last_modified` datetime DEFAULT NULL,
  `file_hash` varchar(64) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `repository_analysis_id` (`repository_analysis_id`),
  KEY `ix_code_files_id` (`id`),
  CONSTRAINT `code_files_ibfk_1` FOREIGN KEY (`repository_analysis_id`) REFERENCES `repository_analyses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversation_summaries`
--

DROP TABLE IF EXISTS `conversation_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversation_summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) NOT NULL,
  `summary_content` text NOT NULL,
  `total_turns` int(11) DEFAULT NULL,
  `tools_used` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tools_used`)),
  `group_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_conversation_summaries_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `correlation_analyses`
--

DROP TABLE IF EXISTS `correlation_analyses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `correlation_analyses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_id` varchar(36) NOT NULL,
  `repository1_id` int(11) NOT NULL,
  `repository2_id` int(11) NOT NULL,
  `common_dependencies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`common_dependencies`)),
  `similar_patterns` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`similar_patterns`)),
  `architecture_similarity` decimal(5,4) DEFAULT NULL,
  `shared_technologies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shared_technologies`)),
  `similarity_score` decimal(5,4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_correlation_analyses_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `development_standards`
--

DROP TABLE IF EXISTS `development_standards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `development_standards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_id` varchar(36) NOT NULL,
  `standard_type` enum('CODING_STYLE','ARCHITECTURE_PATTERN','COMMON_FUNCTIONS','BEST_PRACTICES') NOT NULL,
  `title` varchar(500) NOT NULL,
  `content` text NOT NULL,
  `examples` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`examples`)),
  `recommendations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recommendations`)),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `analysis_id` (`analysis_id`),
  KEY `ix_development_standards_id` (`id`),
  CONSTRAINT `development_standards_ibfk_1` FOREIGN KEY (`analysis_id`) REFERENCES `analysis_requests` (`analysis_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_analyses`
--

DROP TABLE IF EXISTS `document_analyses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_analyses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repository_analysis_id` int(11) NOT NULL,
  `document_path` varchar(1000) NOT NULL,
  `document_type` enum('README','API_DOC','WIKI','CHANGELOG','CONTRIBUTING','OTHER') DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `extracted_sections` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`extracted_sections`)),
  `code_examples` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`code_examples`)),
  `api_endpoints` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`api_endpoints`)),
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `repository_analysis_id` (`repository_analysis_id`),
  KEY `ix_document_analyses_id` (`id`),
  CONSTRAINT `document_analyses_ibfk_1` FOREIGN KEY (`repository_analysis_id`) REFERENCES `repository_analyses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `langflow_tool_mappings`
--

DROP TABLE IF EXISTS `langflow_tool_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `langflow_tool_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flow_id` varchar(255) NOT NULL,
  `context` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `flow_id` (`flow_id`),
  KEY `ix_langflow_tool_mappings_id` (`id`),
  KEY `ix_langflow_tool_mappings_context` (`context`),
  CONSTRAINT `langflow_tool_mappings_ibfk_1` FOREIGN KEY (`flow_id`) REFERENCES `langflows` (`flow_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `langflows`
--

DROP TABLE IF EXISTS `langflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `langflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flow_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `flow_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`flow_data`)),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_langflows_flow_id` (`flow_id`),
  UNIQUE KEY `ix_langflows_name` (`name`),
  KEY `ix_langflows_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `repository_analyses`
--

DROP TABLE IF EXISTS `repository_analyses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `repository_analyses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_id` varchar(36) NOT NULL,
  `repository_url` varchar(500) NOT NULL,
  `repository_name` varchar(255) DEFAULT NULL,
  `branch` varchar(100) DEFAULT 'main',
  `clone_path` varchar(500) DEFAULT NULL,
  `status` enum('PENDING','CLONING','ANALYZING','COMPLETED','FAILED') DEFAULT 'PENDING',
  `commit_hash` varchar(40) DEFAULT NULL,
  `commit_date` datetime DEFAULT NULL,
  `commit_author` varchar(255) DEFAULT NULL,
  `commit_message` longtext DEFAULT NULL,
  `files_count` int(11) DEFAULT 0,
  `lines_of_code` int(11) DEFAULT 0,
  `languages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`languages`)),
  `frameworks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`frameworks`)),
  `dependencies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dependencies`)),
  `ast_data` longtext DEFAULT NULL,
  `tech_specs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tech_specs`)),
  `code_metrics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`code_metrics`)),
  `documentation_files` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`documentation_files`)),
  `config_files` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`config_files`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_repo_analysis_id` (`analysis_id`),
  KEY `ix_repository_analyses_commit_hash` (`commit_hash`),
  KEY `ix_repository_analyses_id` (`id`),
  CONSTRAINT `repository_analyses_ibfk_1` FOREIGN KEY (`analysis_id`) REFERENCES `analysis_requests` (`analysis_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tech_dependencies`
--

DROP TABLE IF EXISTS `tech_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tech_dependencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repository_analysis_id` int(11) NOT NULL,
  `dependency_type` enum('FRAMEWORK','LIBRARY','TOOL','LANGUAGE') NOT NULL,
  `name` varchar(255) NOT NULL,
  `version` varchar(100) DEFAULT NULL,
  `package_manager` varchar(50) DEFAULT NULL,
  `is_dev_dependency` tinyint(1) DEFAULT NULL,
  `license` varchar(100) DEFAULT NULL,
  `vulnerability_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `repository_analysis_id` (`repository_analysis_id`),
  KEY `ix_tech_dependencies_id` (`id`),
  CONSTRAINT `tech_dependencies_ibfk_1` FOREIGN KEY (`repository_analysis_id`) REFERENCES `repository_analyses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vector_embeddings`
--

DROP TABLE IF EXISTS `vector_embeddings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vector_embeddings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_type` enum('CODE','DOCUMENT','AST_NODE') NOT NULL,
  `source_id` int(11) NOT NULL,
  `chunk_id` varchar(100) NOT NULL,
  `collection_name` varchar(255) NOT NULL,
  `embedding_model` varchar(100) DEFAULT NULL,
  `chunk_text` text DEFAULT NULL,
  `node_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`node_metadata`)),
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_vector_embeddings_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-09-11  7:41:59

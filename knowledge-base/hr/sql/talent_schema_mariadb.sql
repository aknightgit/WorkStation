-- HR Core schema (MariaDB)
-- 人才池 / 人才地图 / 企业知识库基础结构

CREATE DATABASE IF NOT EXISTS `HumanResource`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `HumanResource`;

CREATE TABLE IF NOT EXISTS people (
  person_id VARCHAR(64) PRIMARY KEY,
  full_name VARCHAR(128) NOT NULL,
  person_type ENUM('candidate','employee','alumni','external') NOT NULL,
  title VARCHAR(128) NULL,
  department VARCHAR(128) NULL,
  level VARCHAR(64) NULL,
  location VARCHAR(128) NULL,
  phone VARCHAR(64) NULL,
  email VARCHAR(128) NULL,
  source_channel VARCHAR(128) NULL,
  status VARCHAR(32) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_people_dept (department),
  INDEX idx_people_type (person_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS skills (
  skill_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  skill_name VARCHAR(128) NOT NULL UNIQUE,
  skill_category VARCHAR(128) NULL,
  description TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS person_skills (
  person_id VARCHAR(64) NOT NULL,
  skill_id BIGINT NOT NULL,
  proficiency TINYINT DEFAULT 3,
  years_experience DECIMAL(5,2) DEFAULT 0,
  evidence TEXT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(person_id, skill_id),
  CONSTRAINT fk_person_skills_person
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE,
  CONSTRAINT fk_person_skills_skill
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
  CONSTRAINT chk_person_skills_proficiency CHECK (proficiency BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS work_experiences (
  experience_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  person_id VARCHAR(64) NOT NULL,
  company VARCHAR(255) NULL,
  role_title VARCHAR(255) NULL,
  start_date DATE NULL,
  end_date DATE NULL,
  highlights TEXT NULL,
  CONSTRAINT fk_work_exp_person
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS hiring_pipeline (
  pipeline_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  person_id VARCHAR(64) NOT NULL,
  job_id VARCHAR(64) NULL,
  stage VARCHAR(128) NULL,
  interviewer VARCHAR(128) NULL,
  score DECIMAL(5,2) NULL,
  feedback TEXT NULL,
  stage_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_pipeline_person (person_id),
  CONSTRAINT fk_hiring_pipeline_person
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS knowledge_docs (
  doc_id VARCHAR(128) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  doc_type VARCHAR(64) NULL,
  category VARCHAR(128) NULL,
  source_path VARCHAR(512) NULL,
  owner VARCHAR(128) NULL,
  version VARCHAR(64) NULL,
  effective_date DATE NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS knowledge_tags (
  tag_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tag_name VARCHAR(128) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS doc_tags (
  doc_id VARCHAR(128) NOT NULL,
  tag_id BIGINT NOT NULL,
  PRIMARY KEY(doc_id, tag_id),
  CONSTRAINT fk_doc_tags_doc
    FOREIGN KEY (doc_id) REFERENCES knowledge_docs(doc_id) ON DELETE CASCADE,
  CONSTRAINT fk_doc_tags_tag
    FOREIGN KEY (tag_id) REFERENCES knowledge_tags(tag_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS org_nodes (
  node_id VARCHAR(128) PRIMARY KEY,
  node_type ENUM('person','team','role','project') NOT NULL,
  ref_id VARCHAR(128) NULL,
  label VARCHAR(255) NOT NULL,
  attributes_json JSON NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS org_edges (
  edge_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  from_node_id VARCHAR(128) NOT NULL,
  to_node_id VARCHAR(128) NOT NULL,
  relation_type VARCHAR(128) NOT NULL,
  weight DECIMAL(8,3) DEFAULT 1.0,
  attributes_json JSON NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_edges_from_to (from_node_id, to_node_id),
  CONSTRAINT fk_org_edges_from
    FOREIGN KEY (from_node_id) REFERENCES org_nodes(node_id) ON DELETE CASCADE,
  CONSTRAINT fk_org_edges_to
    FOREIGN KEY (to_node_id) REFERENCES org_nodes(node_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

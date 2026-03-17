-- HR Core schema (SQLite)
-- 人才池 / 人才地图 / 企业知识库基础结构

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS people (
  person_id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  person_type TEXT NOT NULL CHECK(person_type IN ('candidate','employee','alumni','external')),
  title TEXT,
  department TEXT,
  level TEXT,
  location TEXT,
  phone TEXT,
  email TEXT,
  source_channel TEXT,
  status TEXT DEFAULT 'active',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS skills (
  skill_id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_name TEXT UNIQUE NOT NULL,
  skill_category TEXT,
  description TEXT
);

CREATE TABLE IF NOT EXISTS person_skills (
  person_id TEXT NOT NULL,
  skill_id INTEGER NOT NULL,
  proficiency INTEGER DEFAULT 3 CHECK(proficiency BETWEEN 1 AND 5),
  years_experience REAL DEFAULT 0,
  evidence TEXT,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(person_id, skill_id),
  FOREIGN KEY(person_id) REFERENCES people(person_id) ON DELETE CASCADE,
  FOREIGN KEY(skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS work_experiences (
  experience_id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id TEXT NOT NULL,
  company TEXT,
  role_title TEXT,
  start_date TEXT,
  end_date TEXT,
  highlights TEXT,
  FOREIGN KEY(person_id) REFERENCES people(person_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS hiring_pipeline (
  pipeline_id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id TEXT NOT NULL,
  job_id TEXT,
  stage TEXT,
  interviewer TEXT,
  score REAL,
  feedback TEXT,
  stage_time TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(person_id) REFERENCES people(person_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS knowledge_docs (
  doc_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  doc_type TEXT,
  category TEXT,
  source_path TEXT,
  owner TEXT,
  version TEXT,
  effective_date TEXT,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS knowledge_tags (
  tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
  tag_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS doc_tags (
  doc_id TEXT NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY(doc_id, tag_id),
  FOREIGN KEY(doc_id) REFERENCES knowledge_docs(doc_id) ON DELETE CASCADE,
  FOREIGN KEY(tag_id) REFERENCES knowledge_tags(tag_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS org_nodes (
  node_id TEXT PRIMARY KEY,
  node_type TEXT NOT NULL CHECK(node_type IN ('person','team','role','project')),
  ref_id TEXT,
  label TEXT NOT NULL,
  attributes_json TEXT,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS org_edges (
  edge_id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_node_id TEXT NOT NULL,
  to_node_id TEXT NOT NULL,
  relation_type TEXT NOT NULL,
  weight REAL DEFAULT 1.0,
  attributes_json TEXT,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(from_node_id) REFERENCES org_nodes(node_id) ON DELETE CASCADE,
  FOREIGN KEY(to_node_id) REFERENCES org_nodes(node_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_people_dept ON people(department);
CREATE INDEX IF NOT EXISTS idx_people_type ON people(person_type);
CREATE INDEX IF NOT EXISTS idx_pipeline_person ON hiring_pipeline(person_id);
CREATE INDEX IF NOT EXISTS idx_edges_from_to ON org_edges(from_node_id, to_node_id);

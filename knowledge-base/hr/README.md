# HR智能知识库 / 人才池基础设施

## 当前状态（已搭建）

✅ 已完成基础能力：

1. **结构化数据库（MariaDB）**
   - 数据库名：`HumanResource`
   - 覆盖：人才池、技能标签、招聘流程、知识文档索引、人才地图（节点/边）
   - Schema：`knowledge-base/hr/sql/talent_schema_mariadb.sql`

2. **结构化数据库（SQLite，本地备用）**
   - 路径：`knowledge-base/hr/hr_core.db`
   - Schema：`knowledge-base/hr/sql/talent_schema.sql`

3. **向量数据库（Chroma 本地持久化）**
   - 路径：`knowledge-base/hr/chroma_db/chroma.sqlite3`
   - Collections：
     - `talent_profiles`（人才画像/简历/评估）
     - `enterprise_kb`（流程、文化、规范）
     - `talent_map`（组织关系/人才地图描述）

4. **离线语义检索能力**
   - 脚本：`knowledge-base/hr/scripts/hr_platform.py`
   - 使用本地 hash embedding（无需外部 API key）

5. **目录与模板**
   - 自动创建 HR 文档目录树
   - 模板：`knowledge-base/hr/templates/*.csv`

---

## 快速开始

### 1) 初始化（MariaDB + Chroma）

```bash
python3 knowledge-base/hr/scripts/hr_platform.py init \
  --structured-backend mariadb \
  --db-host <mariadb_host> \
  --db-port 3306 \
  --db-user <user> \
  --db-password <password> \
  --db-name HumanResource
```

> 也可通过环境变量传参：`HR_DB_HOST/HR_DB_PORT/HR_DB_USER/HR_DB_PASSWORD/HR_DB_NAME`

### 2) 导入文档到向量库

```bash
# 企业知识库（流程/文化/规范）
python3 knowledge-base/hr/scripts/hr_platform.py ingest \
  --source knowledge-base/hr/企业流程 \
  --collection enterprise_kb \
  --category 流程

# 人才资料
python3 knowledge-base/hr/scripts/hr_platform.py ingest \
  --source knowledge-base/hr/人才资料 \
  --collection talent_profiles \
  --category 人才
```

### 3) 语义检索

```bash
python3 knowledge-base/hr/scripts/hr_platform.py search \
  --collection enterprise_kb \
  --query "技术部经理入职流程和审批节点" \
  --top-k 5
```

---

## 目录结构

```
hr/
├── 人才资料/
├── 企业流程/
├── 招聘管理/
├── 员工手册/
├── 制度规范/
├── chroma_db/
├── sql/
│   ├── talent_schema.sql
│   └── talent_schema_mariadb.sql
├── scripts/
│   ├── hr_platform.py
│   └── init_mariadb_hr.py
├── templates/
├── .gitignore
└── hr_core.db (sqlite fallback)
```

---

## 说明

- 这是“基础设施层”搭建，下一步是导入真实 HR 文档/简历/制度。
- 向量库当前为离线可用方案；后续可切换 OpenAI/MiniMax embedding 提升语义质量。

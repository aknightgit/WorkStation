# HR 基础能力搭建说明（人才池 / 人才地图 / 企业知识库）

## 已完成内容

- [x] 本地向量数据库 Chroma 持久化目录
- [x] 人才/知识/地图 3 个 collection 初始化逻辑
- [x] 结构化 MariaDB schema（`HumanResource`）
- [x] 结构化 SQLite fallback schema（本地调试）
- [x] 文档分块 + 向量写入 + 语义检索 CLI
- [x] CSV 模板文件（可直接填充后导入）

---

## 操作命令

### 初始化（推荐：MariaDB）

```bash
python3 knowledge-base/hr/scripts/hr_platform.py init \
  --structured-backend mariadb \
  --db-host <mariadb_host> \
  --db-port 3306 \
  --db-user <user> \
  --db-password <password> \
  --db-name HumanResource
```

### 只初始化本地 SQLite（调试）

```bash
python3 knowledge-base/hr/scripts/hr_platform.py init --structured-backend sqlite
```

### 导入（文档 -> 向量）

```bash
python3 knowledge-base/hr/scripts/hr_platform.py ingest \
  --source knowledge-base/hr/员工手册 \
  --collection enterprise_kb \
  --category 文化

python3 knowledge-base/hr/scripts/hr_platform.py ingest \
  --source knowledge-base/hr/人才资料 \
  --collection talent_profiles \
  --category 人才
```

### 查询

```bash
python3 knowledge-base/hr/scripts/hr_platform.py search \
  --collection talent_profiles \
  --query "有5年以上数据平台经验且有团队管理经历的人才" \
  --top-k 5
```

---

## 关键路径

- 向量库：`knowledge-base/hr/chroma_db/chroma.sqlite3`
- 结构化库（MariaDB）：`HumanResource`（远端实例）
- 结构化库（SQLite fallback）：`knowledge-base/hr/hr_core.db`
- 数据模型：
  - `knowledge-base/hr/sql/talent_schema_mariadb.sql`
  - `knowledge-base/hr/sql/talent_schema.sql`
- 命令脚本：
  - `knowledge-base/hr/scripts/hr_platform.py`
  - `knowledge-base/hr/scripts/init_mariadb_hr.py`

---

## 下一步建议

1. 先导入企业流程/员工手册（知识库）
2. 再导入简历/评估表（人才池）
3. 维护组织关系边（人才地图）
4. 接飞书入口，提供人才检索+制度问答

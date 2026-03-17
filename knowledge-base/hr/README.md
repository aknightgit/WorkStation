# HR智能知识库 / 人才池基础设施

## 当前状态（已搭建）

✅ 已完成基础能力：

1. **结构化数据库（SQLite）**
   - 路径：`knowledge-base/hr/hr_core.db`
   - 覆盖：人才池、技能标签、招聘流程、知识文档索引、人才地图（节点/边）

2. **向量数据库（Chroma 本地持久化）**
   - 路径：`knowledge-base/hr/chroma_db/chroma.sqlite3`
   - Collections：
     - `talent_profiles`（人才画像/简历/评估）
     - `enterprise_kb`（流程、文化、规范）
     - `talent_map`（组织关系/人才地图描述）

3. **离线语义检索能力**
   - 脚本：`knowledge-base/hr/scripts/hr_platform.py`
   - 使用本地 hash embedding（无需外部 API key）

4. **目录与模板**
   - 自动创建 HR 文档目录树
   - 模板：`knowledge-base/hr/templates/*.csv`

---

## 快速开始

### 1) 初始化（只需一次）

```bash
python3 knowledge-base/hr/scripts/hr_platform.py init
```

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
│   ├── 候选人简历/
│   ├── 员工档案/
│   └── 面试评估/
├── 企业流程/
│   ├── 入职流程/
│   ├── 离职流程/
│   ├── 晋升流程/
│   └── 调薪流程/
├── 招聘管理/
│   ├── 职位描述/
│   ├── 招聘渠道/
│   └── 面试题库/
├── 员工手册/
│   ├── 公司简介/
│   ├── 行为准则/
│   └── 福利政策/
├── 制度规范/
│   ├── 考勤制度/
│   ├── 绩效考核/
│   └── 奖惩条例/
├── chroma_db/
├── sql/
│   └── talent_schema.sql
├── scripts/
│   └── hr_platform.py
├── templates/
└── hr_core.db
```

---

## 说明

- 这是“基础设施层”搭建，下一步是你们把真实 HR 文档/简历/制度导入。
- 当前向量库可先离线跑通流程，后续如果要更高精度，可切换到 OpenAI/MiniMax embedding。

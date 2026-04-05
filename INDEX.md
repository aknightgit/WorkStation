# 📂 Workspace 索引

> 最后更新：2026-04-05 08:45 CST

## 📁 项目目录

| 目录 | 用途 | 状态 |
|------|------|------|
| `ChangQingGe-Mahjong/` | 麻将游戏（Node.js 训练器） | 🚧 AI 策略训练中 |
| `LSCN/` | 服装零售经销存 BI 分析（Redshift） | 🚧 进行中 |
| `├─ LSCN/NONPROD/` | **默认工作目录** — 非生产环境（DDL/ETL/部署脚本） | 🚧 活跃 |
| `├─ LSCN/OLDPROD/` | 旧生产环境 | 📌 只读 |
| `├─ LSCN/NEWPROD/` | 新生产环境 | 📌 待配置 |
| `SpendWiseAK-project/` | 记账 App 最新版 | 🚧 开发中 |
| `ClaudeCodeIntegration/` | Claude Code 框架分析与借鉴（P0-P3任务指南） | 📂 参考文档 |
| `MyIsland/` | 个人站点（Nuxt 3） | 🚧 开发中 |
| `scripts/` | 通用脚本（用量采集、知识构建等） | 🔧 维护中 |
| `hr_docs/` | HR 语义搜索（Cara 默认库） | 📂 资料 |
| `deliverables/` | 交付文档（部署指南等） | 📂 存档 |
| `stock/` | 股票分析脚本 | 🔧 维护中 |
| `stock_data/` | 股票历史数据（CSV） | 📂 数据 |
| `knowledge-base/` | 知识库 | 📂 空 |
| `templates/` | 模板文件（飞书卡片等） | 📂 含 usage-report.md |
| `_archive/` | 已废弃项目 | 📦 归档 |
| `Eclipse/` | Java 项目占位（待清理） | 📦 待处理 |

## 📄 核心文件

| 文件 | 用途 |
|------|------|
| `AGENTS.md` | Agent 行为规范 |
| `SOUL.md` | 人格/语气定义 |
| `USER.md` | 用户信息（K哥/Cara/K嫂） |
| `TOOLS.md` | 工具本地笔记+基础设施信息（已合并 infrastructure.md） |
| `MEMORY.md` | 长期记忆 + K哥规则 |
| `HEARTBEAT.md` | 心跳检查清单 |
| `IDENTITY.md` | Agent 身份 |
| `SESSION-STATE.md` | 会话状态 |
| `BOOTSTRAP.md` | 初始化文件 |

> `infrastructure.md` 已合并到 `TOOLS.md`，保持向后兼容

## 📝 记忆 & 学习

| 目录/文件 | 用途 |
|-----------|------|
| `memory/` | 每日日志（YYYY-MM-DD.md） |
| `memory/cron/` | Cron 任务配置 |
| `learnings/LEARNINGS.md` | 经验教训（52 条） |
| `learnings/ERRORS.md` | 错误记录（9 条） |
| `learnings/FEATURE_REQUESTS.md` | 功能需求（5 条） |

## 🔧 Scripts

| 文件 | 用途 |
|------|------|
| `scripts/usage-collector.mjs` | 模型用量采集 |
| `scripts/daily_knowledge_builder.py` | 知识库自动构建 |
| `scripts/memory_service.py` | 长期记忆服务（MariaDB） |

## 🗄️ 数据库

| 数据库 | 用途 |
|--------|------|
| MariaDB `HumanResource` | HR 数据（Cara 默认库） |
| MariaDB `changqingge` | 麻将项目数据 |
| MariaDB `openclaw` | 模型用量统计 |
| MongoDB `changqingge` | 麻将游戏状态 |
| Redis `192.168.3.241:6379` | 缓存 |

## 🤖 本地模型 (Ollama)

| 模型 | 用途 |
|------|------|
| qwen3.5:35b-a3b | 主力文本模型 |
| qwen3.5:9b | 轻量模型（含 vision） |
| qwen2.5:32b-instruct-q4_K_M | 备用文本模型 |

## 📁 数据迁移说明

> 所有 NONPROD/OLDPROD 环境的凭证文件均迁移至 `/data/LS_ENV/` 目录，不纳入 git 管理
> - NONPROD 连接信息：`/data/LS_ENV/NONPROD/NONPROD.md`
> - OLDPROD 连接信息：`/data/LS_ENV/OLDPROD/OLDPROD.md`
> - 本地文档仅作索引指引，不包含任何密码/密钥
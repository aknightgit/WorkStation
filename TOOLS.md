# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## 路径约定（K哥）

- **默认外网下载目录**：`/data/`（下载安装包、临时大文件默认放这里）
- **环境目录**：`/data/LS_ENV/`（含 PPK/配置等，凭证不落盘到工作区）
- 与用户共享/交付的环境说明文档，优先放在 `/data` 下对应目录。

## 全局时区

- **所有项目默认时区：UTC+8（北京时间）**
- 非特殊原因，日志、看板、报告、数据库字段展示全部用 UTC+8
- 特殊原因（如对接外部系统必须用 UTC）需在代码中明确标注

---

## 基础设施信息（已合并，弃用 infrastructure.md）

### 数据库

#### MariaDB (麻将/HR)
- **Host**: 192.168.3.241
- **Port**: 33061
- **User**: openclaw
- **Default DB**: HumanResource
- **Mahjong DB**: changqingge
- ⚠️ 密码在 `/data/LS_ENV/` 下，不在此处

#### OpenClaw 数据库 (MariaDB)
- **数据库**: openclaw
- **用途**: 模型使用量采集、系统数据
- **表**: model_usage

#### MongoDB (极空间NAS)
- **Host**: 192.168.3.241
- **Port**: 27017
- **认证源**: admin
- **Mahjong DB**: changqingge
- ⚠️ 密码在 `/data/LS_ENV/` 下，不在此处

#### Redis
- **Host**: 192.168.3.241
- **Port**: 6379
- **容器**: `redis:latest`（Docker 映射 `0.0.0.0:6379->6379`）
- ⚠️ 密码在 `/data/LS_ENV/` 下，不在此处

### Ollama (本地大模型)
- **Host**: 192.168.3.114
- **Port**: 11434
- **Models**:
  - `qwen3.5:35b-a3b` — 主力文本模型
  - `qwen3.5:9b` — 轻量模型（含 vision 能力）
  - `qwen2.5:32b-instruct-q4_K_M` — 备用文本模型
- ⚠️ **已全域替换**：qwen3-vl:8b → qwen3.5:9b

### GitHub
- **用户**: aknightgit
- **Mahjong仓库**: https://github.com/aknightgit/ChangQingGe-Mahjong
- **记账App仓库**: https://github.com/aknightgit/SpendWiseAK

### SSH Key
- **路径**: ~/.ssh/id_ed25519_openclaw
- **Push命令**: `GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_openclaw -o StrictHostKeyChecking=no" git push`

### 网关 (OpenClaw)
- **Host**: 127.0.0.1
- **Port**: 18789
- ⚠️ Auth Token 在 `/data/LS_ENV/` 下，不在此处

## 基础设施文件规则

- **弃用 `infrastructure.md`**：所有基础设施信息已合并到 `TOOLS.md`
- 如果 `infrastructure.md` 被意外创建，立即删除并合并到 `TOOLS.md`
- **Ollama 模型列表**：qwen3-vl:8b 已全域替换为 qwen3.5:9b，不要写旧模型名
- **凭证文件位置**：所有密码/密钥均存放在 `/data/LS_ENV/` 下，不在此处
  - NONPROD：`/data/LS_ENV/NONPROD/`（含 PPK/OpenSSH 密钥、连接信息）
  - OLDPROD：`/data/LS_ENV/OLDPROD/`
- **NONPROD.md / OLDPROD.md 只写信息指向**：不包含任何密码，仅标注来源路径
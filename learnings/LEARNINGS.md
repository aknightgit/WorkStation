# Learnings Log

> 回顾时间: 2026-03-25
> 回顾范围: 2026-03-17 ~ 2026-03-25

---

## 基础设施 & 运维

### L001 - PPK转PEM密钥转换
- **类别**: tool_gotcha
- **问题**: npm 包 `ppk-to-openssh` 生成的 OpenSSH 格式 key 字段顺序错乱，SSH 报 "incomplete message"
- **解决**: 使用 `sshpk-conv -T putty -t pem -i input.ppk -o output.pem` 可正确转换
- **See Also**: PuTTY 密钥格式解析依赖工具链，Node.js crypto 不支持直接从 PPK 组件导入

### L002 - Redshift reserved word "month"
- **类别**: tool_gotcha
- **问题**: Redshift 中 `month` 是保留字，`EXTRACT(MONTH FROM date) month` 会报语法错误
- **解决**: 用别名如 `sale_month` 或 `cal_month` 替代

### L003 - Redshift pg_table_def 无 attnum 列
- **类别**: tool_gotcha
- **问题**: `pg_table_def` 没有 `attnum` 列用于排序，用 `ORDER BY attnum` 报错
- **解决**: 直接查询 `"column"` 和 `"type"`，不排序

### L004 - Python f-string 注入 SQL 不安全
- **类别**: error_correction
- **问题**: Python f-string 拼 SQL 变量会报 `Unknown column` 因为变量值被当列名
- **解决**: 始终用参数化查询 `conn.execute(sql, [params])`

### L005 - GBK 编码文件读取
- **类别**: tool_gotcha
- **问题**: 中文 Windows 环境导出的 txt 文件可能是 GBK 编码，iconv/直接读会乱码
- **解决**: Python `open(file, 'rb').read().decode('gbk')` 正确读取

### L006 - MariaDB require_secure_transport
- **类别**: tool_gotcha
- **问题**: 连接 RDS MySQL 报 "Connections using insecure transport are prohibited"
- **解决**: 添加 `ssl: { rejectUnauthorized: false }` 连接参数

### L007 - MySQL REPLACE INTO + NULL unique key
- **类别**: error_correction
- **问题**: MySQL unique key 中 NULL != NULL，REPLACE INTO 对 NULL 列不去重
- **解决**: 确保唯一索引的所有列都不为 NULL，或用 COALESCE 设置默认值

### L008 - npm 模块路径在 /tmp 下找不到
- **类别**: error_correction
- **问题**: 在 /tmp 写的脚本 `require('pg')` 报 MODULE_NOT_FOUND
- **解决**: 脚本必须放在 node_modules 所在目录或其子目录下

### L009 - 容器环境无 systemd
- **类别**: tool_gotcha
- **问题**: Docker 容器中 `systemctl --user` 不可用
- **解决**: 用 `openclaw gateway start --force` 前台运行，或用 supervisor

---

## 工作习惯 & 流程

### L010 - NONPROD 凭证不入 workspace 文件
- **类别**: best_practice
- **规则**: NONPROD 环境的 IP/密码/端口不写入 MEMORY.md、infrastructure.md、TOOLS.md
- **原因**: 防止工作区文件被版本控制泄露
- **存放位置**: /data/LS_ENV/ 下对应目录

### L011 - 删除操作必须确认
- **类别**: correction
- **规则**: NONPROD 环境任何删除操作（数据库记录/文件/表）必须事先跟用户确认
- **已知违规**: 2026-03-25 未确认删除了 api_sales 表中 idempotent 测试产生的重复数据

### L012 - 全局时区 UTC+8
- **类别**: best_practice
- **规则**: 所有项目默认使用 UTC+8（北京时间），非特殊原因不用 UTC
- **适用范围**: 日志、看板、报告、数据库字段展示

### L013 - 外网下载默认放 /data
- **类别**: best_practice
- **规则**: 安装包/大文件/临时下载默认放 /data/ 目录

### L014 - 避免重复播报同类文本
- **类别**: correction
- **问题**: 会话中出现过重复回复同类文本的体验问题
- **解决**: 用户已明确关注，回复前检查是否已发过相同内容

### L015 - API 认证设计为渐进式
- **类别**: best_practice
- **规则**: 新 API 加认证时，先做功能（pending/disabled），同步给上游后再开启
- **好处**: 零停机切换，避免上游调用中断

### L016 - 中文环境的错误提示用中文
- **类别**: best_practice
- **规则**: 面向中文用户的表单/错误提示统一用中文

### L017 - 飞书 Bitable 工具不稳定
- **类别**: tool_gotcha
- **问题**: feishu_bitable 工具在子代理中超时，多次重试仍失败
- **解决**: 飞书文档表格作为替代方案，或让用户手动创建 Bitable 后灌数据

### L018 - 节点模块和归档文件不入 git
- **类别**: error_correction
- **问题**: workspace 的 git commit 经常把 node_modules/zip/tar.gz 也提交了
- **解决**: 需要在 workspace 根目录配置 .gitignore

---

## 麻将项目专项

### L019 - AI 训练 fitness 调参
- **类别**: best_practice
- **经验**: fitness 函数中给指标正向权重（如 selfDrawRate * 90）会导致该指标无限趋高
- **正确做法**: 用目标值偏差惩罚（如 -|rate - target| * penalty_weight）
- **目标值推荐**: 自摸率 60-70%, 大牌率 <5%, 门清率 <10%

### L020 - 大吊规则实现
- **类别**: knowledge_gap
- **要点**: 大吊 = 胡牌后手牌仅2张 + 至少有门口副露
- **优先级**: 仅低于风碰(100)和风一色(90)
- **特殊规则**: 碰碰胡大吊/混一色大吊不受"无花不能捉冲"限制

### L021 - git clone 默认分支是 main 不是 master
- **类别**: correction
- **问题**: 2026-03-24 告诉用户"不用 checkout master"，但用户克隆的仓库默认分支是 main，导致用户白忙活 20 分钟
- **教训**: 不要武断地说"不用切换分支"，应该先 `git branch` 确认当前分支名
- **规则**: clone 后先 `git branch -a` 确认分支，再做判断

### L022 - 训练输出目录需用 training-output 不是 training
- **类别**: correction
- **问题**: 训练输出默认写到 training/ 目录，但用户审核用的是 training-output/
- **解决**: 改 PROJECT_TRAINING_DIR 为 training-output
- **规则**: 麻将训练输出同步到项目 training-output 目录供审核

---

## 2026-03-26 新增 Learnings

### L021 - git pull 前必须先确认代码版本
- **类别**: work_habit
- **问题**: K哥 Windows 代码落后 18 个 commit 但一直在测试旧代码，我反复说"代码没问题"实际不是
- **解决**: 每次协作前先让对方跑 `git log --oneline -3` + `git status` 确认版本一致
- **影响**: 导致了 2 小时的无效调试

### L022 - package-lock.json 冲突阻止 git pull
- **类别**: tool_gotcha
- **问题**: `git pull` 因 package-lock.json 本地改动被 abort，导致代码一直停在旧版本
- **解决**: `git restore package-lock.json` 或 `git checkout -- package-lock.json` 后再 pull

### L023 - Nuxt @nuxt/fonts Google Fonts 超时
- **类别**: tool_gotcha
- **问题**: @nuxt/ui 内部的 @nuxt/fonts 模块自动尝试连接 Google Fonts，30 秒超时
- **解决**: `fonts: false`、`$development: { fonts: false }`、`unifont.providers: []` 均不生效。唯一方案是 patch node_modules: 注释掉 module.mjs 中的 google/googleicons provider
- **持久化**: 创建 `scripts/patch-fonts.mjs`，postinstall 链自动执行

### L024 - Nuxt dev 模式 Socket.IO ECONNABORTED
- **类别**: tool_gotcha
- **问题**: dev 模式文件监控触发重启，重启过程中 Socket.IO 连接被打断，整个 dev server 崩溃
- **解决**: 生产模式 (`npm run build && npm run preview`) 无此问题。dev 模式下需添加 `/socket.io/` catch-all route 防 Vue Router 劫持

### L025 - PowerShell 不支持 &&
- **类别**: tool_gotcha
- **问题**: `npm run build && npm run preview` 在 PowerShell 报语法错误
- **解决**: 分开执行或用 `;` 替代

### L026 - 训练参数解析用位置参数而非 flags
- **类别**: error_correction
- **问题**: `npx tsx train-ai.ts --rounds 5 --games 2000` 参数被解析为 NaN，退回到默认值
- **解决**: 改用 `process.argv` 解析 `--rounds` 和 `--games` flags

### L027 - 文件名含 +8 后缀导致写入失败
- **类别**: error_correction
- **问题**: `new Date().toISOString().replace('Z', '+8')` 生成的文件名目录能创建但文件写不进去
- **解决**: 用 `-08` 替代 `+8`

### L028 - 看截图要实事求是，不能瞎编
- **类别**: work_habit
- **问题**: 我看 K哥 的截图后编造牌面内容（具体是什么牌），被批评"睁眼瞎"
- **解决**: 截图只描述能确认的元素，看不清就说看不清

### L029 - 不要假设参考图就是目标
- **类别**: work_habit
- **问题**: 项目 screenshots/ 目录有旧设计图，我以为是目标效果，K哥说"简陋！难看！奇丑无比"
- **解决**: 改造 UI 前必须确认设计目标，让客户发参考图

### L030 - OpenClaw cron session 泄漏
- **类别**: tool_gotcha
- **问题**: cron 创建的 isolated session 完成后不自动清理，sessions.json 越堆越多导致卡死
- **解决**: 创建清理 cron（每 30 分钟清理 1 小时不活跃的 cron/subagent session）+ 每日凌晨 5:00 CST reset 主对话

---

## 2026-03-27 — K哥 GitHub 调试规范（来源：K哥反馈）

**背景**：在和 K哥 调试 ChangQingGe-Mahjong 时，双方对同一个问题的判断完全基于不同版本的代码，导致沟通无效。K哥测试的是本地旧版本，而我在修复最新版本。

**教训**：
- 涉及 GitHub 协作时，**必须先确认双方都 push/pull 到相同版本**，再开始正式测试
- 如果发现版本不一致，应该立即停止调试，先同步版本
- 任何 commit / merge 后都应该通知 K哥 pull 并确认版本

**规则**：
1. push 后告知 K哥 git pull 并确认版本 hash 一致
2. 测试前互相确认 HEAD commit ID
3. 如果 K哥 测试结果和预期不符，第一时间检查版本是否同步


## 2026-03-27 经验总结

### 1. 模板编辑：删除代码块时必须检查闭合标签
删除 `<div class="center-actions">` wrapper 时，我只删了内容但多留了一个 `</div>`，导致 Vue 模板解析失败（`<main>` 找不到闭合标签）。教训：删除代码块时，必须同时删除对应的开闭标签对，编辑后立即验证 HTML/模板结构。

### 2. MongoDB ECONNABORTED：每一层调用链都要 try-catch
`hydrateFromDatabase()` 加了 try-catch，但 `ensureGameLoaded()` → `loadGameState()` 没有，导致 unhandledRejection 触发 Nuxt 重启。教训：MongoDB 操作不是加一个 try-catch 就够的，必须追查所有调用路径，每一层都保护。

### 3. Vue 条件渲染 vs 禁用状态
`v-if="isConnected"` 会让组件完全不渲染（消失），而不是变灰禁用。如果需要"永远显示但未连接时禁用"，应该用 `v-if` 移除，改为 `:disabled="!isConnected"` + CSS `.class--offline { opacity: 0.5; }`。

### 4. 批量文件处理的并发策略
659 张图片逐张分析太慢（~3.6 小时），用 `ThreadPoolExecutor(2)` 并发可缩短到 ~1 小时。但 Ollama 本地模型不支持太多并发，2 个 worker 是合理上限。

### 5. 模型选择：识图准确性 > 规模
qwen3.5:9b 比 qwen3-vl:8b 识图更准确——不会幻觉捏造内容。对于"如实描述"任务（麻将牌面识别、图片分类），小模型 + 准确 > 大模型 + 幻觉。

### 6. 配置变更后需要 session 刷新
models.json / openclaw.json 的变更不会立即影响当前 session，需要 gateway restart 或新 session 才生效。容器内 systemd 不可用，需要用 `openclaw gateway start` 前台启动。

### 7. qwen3.5:9b 有 vision 能力，不要想当然
qwen3.5:9b 的 capabilities 包含 vision，可以识别图片。不要因为"qwen3.5 系列"就假设它没有 vision——每个子版本能力可能不同。判断前先查 `ollama show`。

---

## 2026-04-01 ~ 2026-04-05 新增 Learnings

### L043 - canWin 公式：14 - 2*melds → 14 - 3*melds
- **类别**: error_correction
- **问题**: canWin 手牌数校验公式用 `14 - 2*melds`，实际每副露消耗 3 张牌
- **解决**: 改为 `14 - 3*melds`
- **影响**: 导致胡牌判定错误，AI 训练数据污染

### L044 - tryFormMelds cnt>3 只消耗 3 张
- **类别**: error_correction
- **问题**: tryFormMelds 在手牌某牌 cnt>3 时会消耗全部牌而非只取 3 张
- **解决**: 限制消耗数量为 3
- **影响**: 多张相同牌时组副露逻辑错误

### L045 - 没有"普通胡/基础胡"牌型
- **类别**: domain_knowledge
- **规则**: K哥铁律——所有赢牌必须是目标牌型之一（风一色、风碰、清碰、混碰、清一色、混一色、八花、四百搭、碰碰胡、大吊）
- **影响**: 之前代码中有通用胡牌检验，需移除

### L046 - 风一色不需要检验 3n+2
- **类别**: domain_knowledge
- **规则**: 风一色全部由风牌+箭牌组成，不需要标准 3n+2 检验
- **例外**: 风碰 = 风一色 + 碰碰胡，需要检验 3n+2

### L047 - 弃牌策略优先级
- **类别**: domain_knowledge
- **规则**: 最短门单张(已现>2) → 最短门单张 → 风箭(已现≥3) → 最短门对子

### L048 - SpendWiseAK MongoDB 直连方案
- **类别**: best_practice
- **经验**: APK 调试版直接连 MongoDB 比走 API 更高效
- **产出**: /data/download/糊涂账-debug.apk

### L049 - ClaudeCode 源码审查
- **类别**: best_practice
- **经验**: 用 coco (GPT-5.3-codex) 做深度代码审查，覆盖面广

### L050 - 4AI 模拟器 SIGTERM 超时问题
- **类别**: error_correction
- **问题**: 4AI 完整游戏模拟器 v8 在 200 轮×500 局规模下被 SIGTERM 杀掉
- **原因**: 执行时间超过 exec 超时限制
- **解决**: 降低规模（5×200）或增加超时时间

### L051 - openai-codex 端点配置
- **类别**: tool_gotcha
- **问题**: capi.quan2go.com 需用 `/v1` + `openai-completions`，不能用 `/openai` + `openai-responses`
- **影响**: 模型调用失败

### L053 - Stash 不是备份，重要改动必须 commit
- **类别**: work_habit
- **问题**: 3/28 确立的四项规则只存在 git stash 里，没有 commit。3/25 的 commit `1ad635e` 把 MEMORY.md 覆盖回最简版，升级重启后加载的是旧版本
- **教训**: stash 是临时存放，不是备份。workspace 核心文件（SOUL/MEMORY/AGENTS/TOOLS/INDEX）的改动必须 commit
- **规则**: 改完核心文件 → 立即 commit + push

### L054 - commit 质量：全量保存会覆盖精心整理的内容
- **类别**: error_correction
- **问题**: commit `1ad635e` 是一次"全量保存"，把 MEMORY.md 覆盖回最简版，同时把 node_modules、二进制文件、明文密码全推上了 git
- **教训**: commit 前必须 `git diff` 检查变更范围，不要批量 add 所有文件
- **规则**: 核心文件单独 commit，二进制/node_modules/凭证绝不入 git

### L055 - OpenClaw 升级会重新从 git 加载 workspace 文件
- **类别**: tool_gotcha
- **问题**: 升级 3.8→2026.4.2 后 gateway 重启，从 git 加载 workspace 文件——加载的是最新 commit 版本，不是 stash 版本
- **教训**: 升级前确保所有重要改动已 commit

### L056 - 前端 Vue/CSS 编辑教训
- **类别**: error_correction
- **Vue CSS 编辑**：不要 sed 批量替换，用 edit 精确修改
- **build 报错**：先 git diff，不要直接 git checkout（曾导致所有前端改动丢失）
- **Sandbox 限制**：没有 JDK/Android SDK，无法构建 Android APK

### L057 - Coco Subagent 调教经验
- **类别**: best_practice
- **模型**: `NewAPI/gpt-5.3-codex` (memecode.de)
- 早期 6-10秒退出不执行 → 加"⚠️ 批评"警告后执行率显著提高
- 任务里写"必须 build → cp → ls -lh 验证"能有效约束 coco

### L058 - 模型配置必须改两处
- **类别**: tool_gotcha
- 添加新模型必须同时改：
  1. `openclaw.json` → `agents.defaults.models`（别名定义）
  2. `agents/main/agent/models.json` → `providers.openrouter.models`（模型注册）
- 两者缺一不可，否则 gateway 的 `buildAllowedModelSet` 会跳过该模型

### L052 - 出牌前后手牌数规律
- **类别**: domain_knowledge
- **规则**: 出牌前 2/5/8/11/14，出牌后 1/4/7/10/13
- **用途**: 校验游戏状态合法性

---

## 2026-03-28 实战经验（麻将 Bug 修复 + UI 增强）

### L031 - CSS 组件级 scoped 不生效 → 全局 :deep()
- **类别**: error_correction
- **问题**: DiscardZone 组件内写 CSS 定位，在嵌套组件中样式被 scoped 隔离不生效
- **解决**: 把关键定位样式移到父组件用 `:deep()` 全局覆盖

### L032 - 事件风暴 debounce + state diff
- **类别**: error_correction
- **问题**: gameStateUpdate 事件频繁触发导致页面抖动/刷新
- **解决**: 500ms debounce + 仅在 state 实际变化时才刷新

### L033 - AI 补花死循环：处理后必须移除 meld
- **类别**: error_correction
- **问题**: replaceFlowers() 处理花牌后未从 meld 集合移除，modulo 永远命中同一组
- **解决**: 处理完的花牌 meld 必须从数据源移除

### L034 - SSR 环境的浏览器 API 必须包 guard
- **类别**: error_correction
- **问题**: useSound.ts 等模块直接访问 window/document，SSR 时 TDZ 报错
- **解决**: 凡是浏览器 API（window/document/navigator）用 `if (import.meta.client)` 或 `process.client` 保护

### L035 - 麻将牌排列：只长边贴靠
- **类别**: domain_knowledge
- **规则**: 所有麻将牌陈列（手牌、牌墙、弃牌区）只能长边贴靠，不能短边相连（头尾相连）。这是麻将的物理规则，牌是竖长方体。

### L036 - 左右家牌头旋转：rotate(90/270deg)
- **类别**: error_correction
- **问题**: 左右家牌头朝向用硬编码 pixel 坐标实现，不同屏幕尺寸错位
- **解决**: seat-left rotate(90deg), seat-right rotate(270deg)，CSS transform 天然适配

### L037 - 弃牌区用 grid + gap 布局
- **类别**: best_practice
- **问题**: 弃牌区每张牌用绝对定位算 pixel 坐标，维护困难
- **解决**: CSS grid + gap 自动排列，不要硬算坐标

### L038 - 观赛锁定模式：防作弊设计
- **类别**: domain_knowledge
- **说明**: 观赛锁定（选一家后不可切换）不是体验优化，是防作弊——防止一人打牌、一人自由观赛传递信息。当前设计防君子不防小人，以后可能放开限制。

### L039 - VL 识牌：整图 > 单张小图
- **类别**: best_practice
- **说明**: vision 模型看整张 tile sheet（含上下文）的识别准确率 > 看单张裁切小图。先出 contact sheet 全览，再逐个验证命名。Grid 步长要跟实际牌宽一致（~68px）。

### L040 - 战斗风格统计 > 输赢盘数
- **类别**: domain_knowledge
- **说明**: RoomStats 用"捉冲占比+均点"和"自摸占比+均点"比单纯输赢盘数更能反映玩家风格特征。

### L041 - 简报数据必须实时查询，不用旧数据糊弄
- **类别**: work_habit
- **问题**: 之前发用量简报时照搬模板里的旧数据（09:44 CST 的快照），模型状态全是错的
- **解决**: 简报数据每次必须实时获取——查 Ollama 在线状态、查 session_status、查 MariaDB model_usage。模板只是格式参考，不是数据源。
- **规则**: 模板里标注"⚠️ 实时查询"，发简报前先查再写

### L042 - 文件系统管理：目录清晰 + 索引维护
- **类别**: work_habit
- **问题**: workspace 根目录堆满散落文件（脚本、图片、补丁），没有索引，找不到东西
- **解决**: 
  1. 新文件必须归入对应项目目录，不散落 workspace 根
  2. 维护 `INDEX.md` 作为目录索引，新增文件/目录时同步更新
  3. 临时脚本放 `scripts/`，项目脚本放项目 `scripts/`
  4. 废弃项目移入 `_archive/`
- **规则**: 文件落地即归位，索引随更

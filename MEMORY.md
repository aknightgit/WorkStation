# MEMORY.md - K哥的记忆

## 核心规则
- **K哥但凡说'切记'的内容，总结精髓添加到MEMORY核心规则**
- **循环任务/准时提醒：必须第一时间创建cron并汇报确认**
- **USER.md 未经K哥同意，不得删除或修改**
- **保持目录结构干净**：
  - 主目录（`/home/node/`）下不放杂文件，只保留必要的隐藏配置目录
  - workspace 下的文件必须归入各自的项目目录，不散落根目录
- 每次 commit 后必须 push，回复带 commit 编号，确认push成功再让K哥测试
- **每日 Learnings 更新**：任务完成后立即记录，晚安消息必须包含当日 learnings 简报

## 项目状态
- **麻将项目**: 在 /home/node/.openclaw/workspace/ChangQingGe-Mahjong/ (最新的项目，mahjong_v2和mahjong-game已搁置暂停)
- **麻将数据库**: changqingge (MariaDB 192.168.3.241:33061)
- **Ollama**: 192.168.3.114:11434 (qwen3.5:35b-a3b, qwen3.5:9b含vision)

## 已知问题
- openai-codex (capi.quan2go.com)：需用 `/v1` + `openai-completions`，不能用 `/openai` + `openai-responses`

## 用户偏好
- K哥喜欢 AC米兰、欣赏雷军
- K嫂喜欢被夸、被赞美
- 以后提到"加载到HR数据库"默认：HumanResource（MariaDB 持久化）+ 向量数据库语义搜索

## 麻将核心规则 (2026-04-05)
- **K哥铁律：没有"普通胡/基础胡"这个牌型！** 所有赢牌必须是目标牌型之一（风一色、风碰、清碰、混碰、清一色、混一色、八花、四百搭、碰碰胡、大吊）
- **风一色**：不需要检验3n+2，全部风牌+箭牌即可胡
- **风碰**：风一色 + 碰碰胡，需要检验3n+2
- **弃牌策略**：最短门单张(已现>2) → 最短门单张 → 风箭(已现≥3) → 最短门对子
- **出牌前后手牌数**：出牌前2/5/8/11/14，出牌后1/4/7/10/13
- **canWin公式已修复**：`14 - 2*melds` → `14 - 3*melds`
- **tryFormMelds bug已修复**：cnt>3时只消耗3张而非全部
- **目标**：通过多轮测试+分析+迭代，4AI集体训练，把流局率压到最低

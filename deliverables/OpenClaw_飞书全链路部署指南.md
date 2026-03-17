# OpenClaw 飞书全链路部署指南

> 适用对象：第一次接触 NAS、OpenClaw、MiniMax、飞书开放平台的普通用户
>
> 目标：在极空间通过官方 App 安装 OpenClaw，接入 MiniMax M2.5，创建飞书 Bot，并完成“飞书 Bot ↔ OpenClaw”全链路验收。
>
> 说明：本文优先依据本机 OpenClaw 文档编写，尤其参考了 `docs/channels/feishu.md`、`docs/channels/pairing.md`、`docs/providers/minimax.md`、`docs/gateway/configuration-reference.md`。极空间 App 的页面名称可能会随固件版本略有差异，但操作思路一致。

---

## 一、先看结论：最小可用清单（MVP）

如果你只想先跑通最小闭环，至少要满足下面 7 项：

1. 极空间里已经安装并启动 OpenClaw 官方 App。
2. 你能进入 OpenClaw 的终端环境，或者能通过 SSH 登录极空间执行命令。
3. 你已经准备好一个可用的 `MINIMAX_API_KEY`。
4. OpenClaw 已识别出模型 `minimax/MiniMax-M2.5`。
5. 飞书开放平台里已经创建企业自建应用，并开启了 Bot 能力。
6. 飞书应用已添加事件 `im.message.receive_v1`，并完成发布。
7. 你给 Bot 发私聊后，已经在 OpenClaw 里完成 pairing（配对批准），机器人能正常回复。

只要这 7 项打勾，整条链路基本就通啦。

---

## 二、部署前准备

### 2.1 你需要准备什么

- 一台已经联网并能正常使用的极空间 NAS
- 一个极空间手机 App（或管理后台）账号
- 一个飞书账号，并且有权限进入飞书开放平台
- 一个 MiniMax 账号
- 一台电脑，用来复制命令、保存密钥、做首次验收

### 2.2 建议准备的占位信息

把下面这些信息先记到你自己的密码管理器或笔记里：

- `YOUR_MINIMAX_API_KEY`
- `YOUR_FEISHU_APP_ID`（格式通常像 `cli_xxx`）
- `YOUR_FEISHU_APP_SECRET`
- `YOUR_FEISHU_PAIRING_CODE`（首次私聊机器人后才会拿到）

### 2.3 敏感信息提醒

下面这些内容都不要截图发群里，也不要提交到 Git：

- MiniMax API Key
- 飞书 App Secret
- OpenClaw 配置文件里的明文密钥
- pairing 批准过程里的敏感标识

如果你怀疑泄露了，最稳妥的处理是：**立刻重置密钥，然后重启 OpenClaw 网关。**

---

# 三、步骤 1：在极空间通过官方 App 安装 OpenClaw

> 这一节的目标很简单：把 OpenClaw 装上，并确认它处于“可运行、可进入终端、可查看状态”的状态。

## 3.1 从极空间 App 安装 OpenClaw

### 操作位置

- 极空间手机 App
- 或极空间管理后台中的“应用中心 / 官方应用 / App Center”

### 操作步骤

1. 打开极空间 App。
2. 进入 **应用中心**。
3. 在搜索框里输入 **OpenClaw**。
4. 找到 OpenClaw 官方应用后，点击 **安装**。
5. 等待下载、部署、启动完成。
6. 安装完成后，进入 OpenClaw 的应用详情页。

### 你需要关注的输入项

通常不需要填写很多内容，但如果界面要求你选择：

- 安装位置：优先选系统推荐默认项
- 数据目录：保持默认，除非你明确知道自己在做什么
- 端口映射：如果 App 已封装好，一般不用手改

### 预期结果

你应该能看到以下至少一项：

- 应用状态显示为“运行中”
- 可以打开应用详情页
- 可以看到日志入口、终端入口，或 Web 管理入口

### 常见报错与排查

#### 报错 1：应用中心搜不到 OpenClaw

排查顺序：

1. 先确认极空间系统和 App Center 已升级到最新版本。
2. 确认你使用的是官方应用仓库，而不是第三方仓库筛选页面。
3. 退出 App 后重新进入，再搜索一次。
4. 如果还是没有，说明你的机型、固件版本或应用市场区域可能暂未上架，需要联系极空间官方支持确认。

#### 报错 2：安装后一直是“启动中”

排查顺序：

1. 看应用日志是否有端口冲突。
2. 看 NAS 剩余空间是否不足。
3. 重启一次 OpenClaw 应用。
4. 仍不行，再重启极空间后重试。

#### 报错 3：能安装但打不开

排查顺序：

1. 确认你当前网络和 NAS 在同一可访问网络里。
2. 检查极空间 App 是否有局域网访问权限。
3. 检查 OpenClaw 应用是否真的“已运行”。

---

## 3.2 进入 OpenClaw 终端或 SSH 环境

> 后面配置 MiniMax 和飞书，通常都需要执行 OpenClaw 命令。最省心的方式有两个：
>
> - 方式 A：极空间 App 里直接进入 OpenClaw 应用终端
> - 方式 B：通过 SSH 登录极空间，然后执行 `openclaw` 命令

### 操作位置

- OpenClaw 应用详情页中的终端入口
- 或电脑上的 SSH 工具

### 操作步骤

1. 打开 OpenClaw 的终端，或者 SSH 登录 NAS。
2. 输入下面命令确认 OpenClaw CLI 可用：

```bash
openclaw gateway status
```

3. 如果提示未初始化，可以执行：

```bash
openclaw setup --wizard
```

或：

```bash
openclaw onboard
```

### 预期结果

至少满足下面一个：

- 命令能正常执行，不报 `command not found`
- 能看到 OpenClaw 网关状态
- 能进入 OpenClaw 的初始化向导

### 常见报错与排查

#### 报错 1：`openclaw: command not found`

排查顺序：

1. 确认你进入的是 OpenClaw 应用自带终端，而不是别的容器终端。
2. 如果是 SSH 登录 NAS，尝试执行 `which openclaw`。
3. 如果还是找不到，说明官方 App 可能尚未完成初始化，先回到应用页面确认它已成功启动。

#### 报错 2：`gateway status` 显示未运行

可尝试：

```bash
openclaw gateway start
```

或：

```bash
openclaw gateway restart
```

然后再看：

```bash
openclaw gateway status
```

---

# 四、步骤 2：注册 MiniMax M2.5 并获取可用凭据

> 这一节推荐走 **API Key** 路线。原因很简单：对 NAS 部署最稳、最直观、最好排查。

## 4.1 注册 MiniMax 账号

### 操作位置

- MiniMax 官网 / 控制台

### 操作步骤

1. 打开 MiniMax 官网并完成注册登录。
2. 如果平台要求实名认证、组织认证、套餐开通或充值，按平台提示完成。
3. 进入控制台中与 API、Open Platform、密钥管理相关的页面。

### 预期结果

你应该已经拥有一个能进入控制台的 MiniMax 账号。

### 常见报错与排查

#### 报错 1：只有产品介绍页，没有 API 控制台入口

排查顺序：

1. 确认你登录的是开发者控制台，而不是纯营销页。
2. 查找页面中的 **API Key**、**密钥管理**、**Open Platform**、**开发者中心** 等入口。
3. 如果账号刚注册，可能需要先完成手机号验证、邮箱验证或开通开发者权限。

---

## 4.2 创建 API Key

### 操作位置

- MiniMax 控制台中的 **API Key / 密钥管理** 页面

### 操作步骤

1. 点击 **创建 API Key**。
2. 给密钥起一个好识别的名字，例如：`openclaw-nas`。
3. 复制生成后的密钥，保存为：

```text
YOUR_MINIMAX_API_KEY
```

### 输入项建议

- 密钥名称：建议与实际用途对应，例如 `openclaw-prod`、`openclaw-test`
- 权限范围：如果平台支持最小权限，优先选择仅 API 调用所需的权限

### 预期结果

你应该拿到一串可复制的 API Key，并且它在控制台里状态正常。

### 常见报错与排查

#### 报错 1：创建成功后再也看不到完整密钥

这是正常现象。多数平台只会显示一次完整密钥。

解决方式：

- 如果忘记保存，直接删除旧 Key，重新创建新 Key。

#### 报错 2：拿到 Key 但实际调用失败

排查顺序：

1. 看账号是否真的开通了 API 能力。
2. 看套餐余额 / 试用额度是否已耗尽。
3. 看 Key 是否被禁用或限制了来源。
4. 必要时新建一个 Key 再测。

---

## 4.3 明确本文使用的 MiniMax 接入方式

本文后续采用的是 OpenClaw 官方文档中推荐的 **MiniMax API Key + Anthropic 兼容接口** 配置方式，关键点如下：

- 环境变量名：`MINIMAX_API_KEY`
- 推荐 `baseUrl`：`https://api.minimax.io/anthropic`
- 推荐 `api`：`anthropic-messages`
- 推荐模型 ID：`MiniMax-M2.5`
- 完整模型引用：`minimax/MiniMax-M2.5`

---

# 五、步骤 3：把 MiniMax 配置到 OpenClaw

> 你可以走两条路：
>
> - 路线 A：用 `openclaw configure` 交互式配置（更适合小白）
> - 路线 B：手动改 `~/.openclaw/openclaw.json`（更适合会看配置文件的人）

## 5.1 路线 A：交互式配置 MiniMax（推荐）

### 操作位置

- OpenClaw 终端 / SSH

### 操作步骤

1. 执行：

```bash
openclaw configure
```

2. 进入 **Model/auth**。
3. 选择 **MiniMax M2.5**。
4. 按提示填入你的 `YOUR_MINIMAX_API_KEY`。
5. 如果系统提示选择默认模型，选择：

```text
minimax/MiniMax-M2.5
```

6. 完成后重启网关：

```bash
openclaw gateway restart
```

### 预期结果

执行下面命令时，列表里应能看到 MiniMax：

```bash
openclaw models list
```

如果你想手动切换默认模型，可以再执行：

```bash
openclaw models set minimax/MiniMax-M2.5
```

### 常见报错与排查

#### 报错 1：`Unknown model: minimax/MiniMax-M2.5`

这是 OpenClaw 官方文档里提到的常见问题，通常意味着 **MiniMax provider 没有正确配置**。

排查顺序：

1. 确认 `MINIMAX_API_KEY` 已写入配置。
2. 确认模型名大小写完全正确：
   - 正确：`minimax/MiniMax-M2.5`
   - 错误示例：`minimax/minimax-m2.5`
3. 重启网关：

```bash
openclaw gateway restart
```

4. 再次执行：

```bash
openclaw models list
```

---

## 5.2 路线 B：手动修改配置文件（进阶）

### 操作位置

- 文件：`~/.openclaw/openclaw.json`

### 推荐配置示例

```json5
{
  env: {
    MINIMAX_API_KEY: "YOUR_MINIMAX_API_KEY",
  },
  agents: {
    defaults: {
      models: {
        "minimax/MiniMax-M2.5": { alias: "minimax" },
      },
      model: {
        primary: "minimax/MiniMax-M2.5",
      },
    },
  },
  models: {
    mode: "merge",
    providers: {
      minimax: {
        baseUrl: "https://api.minimax.io/anthropic",
        apiKey: "${MINIMAX_API_KEY}",
        api: "anthropic-messages",
        models: [
          {
            id: "MiniMax-M2.5",
            name: "MiniMax M2.5",
            reasoning: true,
            input: ["text"],
            cost: { input: 0.3, output: 1.2, cacheRead: 0.03, cacheWrite: 0.12 },
            contextWindow: 200000,
            maxTokens: 8192,
          },
          {
            id: "MiniMax-M2.5-highspeed",
            name: "MiniMax M2.5 Highspeed",
            reasoning: true,
            input: ["text"],
            cost: { input: 0.3, output: 1.2, cacheRead: 0.03, cacheWrite: 0.12 },
            contextWindow: 200000,
            maxTokens: 8192,
          },
        ],
      },
    },
  },
}
```

### 保存后执行

```bash
openclaw gateway restart
openclaw models list
```

### 预期结果

- OpenClaw 能识别 `minimax/MiniMax-M2.5`
- 你能把它设置成默认模型

### 常见报错与排查

#### 报错 1：配置文件改完后启动失败

排查顺序：

1. 检查 JSON5 括号、逗号、引号是否写错。
2. 确认 `${MINIMAX_API_KEY}` 对应的 `env.MINIMAX_API_KEY` 已存在。
3. 执行：

```bash
openclaw gateway status
```

4. 再查看日志：

```bash
openclaw logs --follow
```

#### 报错 2：模型存在，但回答报鉴权错误

排查顺序：

1. 确认 Key 没复制错。
2. 确认 Key 未过期、未禁用。
3. 确认账号仍有可用额度。
4. 重新生成 Key，并替换旧值后重启。

---

# 六、步骤 4：在飞书创建 Bot 应用，并配置到 OpenClaw

> 这一节最关键。OpenClaw 官方文档明确说明：Feishu 插件已经随当前版本一起打包，不需要额外安装插件。你要做的重点是：**创建应用、开权限、开 Bot、开长连接事件、发布应用、把凭据填回 OpenClaw。**

## 6.1 在飞书开放平台创建应用

### 操作位置

- 飞书开放平台：`https://open.feishu.cn/app`
- 国际版 Lark：`https://open.larksuite.com/app`

### 操作步骤

1. 登录飞书开放平台。
2. 点击 **创建企业自建应用**。
3. 填写应用名称、描述、图标。
4. 创建完成后，进入 **凭证与基础信息**。
5. 复制以下两项：
   - `YOUR_FEISHU_APP_ID`
   - `YOUR_FEISHU_APP_SECRET`

### 输入项建议

- 应用名称：建议直接叫 `OpenClaw助手`、`NAS智能助手` 这类容易识别的名字
- 图标：选一个你团队容易认出的图标

### 预期结果

你应当能看到类似下面格式的 App ID：

```text
cli_xxx
```

### 常见报错与排查

#### 报错 1：找不到 App Secret

排查顺序：

1. 确认你进入的是 **凭证与基础信息** 页面。
2. 部分界面需要管理员权限才可查看或重置 Secret。
3. 如果 Secret 泄露，直接在平台里重置，不要继续用旧值。

---

## 6.2 配置飞书应用权限

### 操作位置

- 飞书开放平台 → 应用 → **权限管理**

### 操作步骤

1. 打开 **权限管理**。
2. 选择 **批量开通 / Batch import**。
3. 粘贴下面这段 OpenClaw 官方文档给出的权限 JSON：

```json
{
  "scopes": {
    "tenant": [
      "aily:file:read",
      "aily:file:write",
      "application:application.app_message_stats.overview:readonly",
      "application:application:self_manage",
      "application:bot.menu:write",
      "cardkit:card:read",
      "cardkit:card:write",
      "contact:user.employee_id:readonly",
      "corehr:file:download",
      "event:ip_list",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:chat.members:bot_access",
      "im:message",
      "im:message.group_at_msg:readonly",
      "im:message.p2p_msg:readonly",
      "im:message:readonly",
      "im:message:send_as_bot",
      "im:resource"
    ],
    "user": [
      "aily:file:read",
      "aily:file:write",
      "im:chat.access_event.bot_p2p_chat:read"
    ]
  }
}
```

4. 保存权限配置。

### 预期结果

权限列表中应能看到和消息接收、消息发送、资源访问相关的权限已经开通。

### 常见报错与排查

#### 报错 1：机器人能收到消息，但回不去

重点检查：

- 是否已开通 `im:message:send_as_bot`
- 应用是否已经发布

#### 报错 2：保存权限后还是不生效

排查顺序：

1. 确认保存成功。
2. 如果平台要求发布后生效，继续完成发布流程。
3. 更新权限后，建议重新启动 OpenClaw 网关一次。

---

## 6.3 开启 Bot 能力

### 操作位置

- 飞书开放平台 → **应用能力 / App Capability** → **Bot**

### 操作步骤

1. 进入 Bot 能力页面。
2. 开启 **Bot 能力**。
3. 设置机器人名称。

### 预期结果

在应用能力页能看到 Bot 已启用。

### 常见报错与排查

#### 报错：后面加到群里还是搜不到机器人

排查顺序：

1. 先确认 Bot 能力真的开启。
2. 再确认应用已经发布。
3. 必要时重新进入飞书客户端搜索应用名称。

---

## 6.4 配置事件订阅（长连接 WebSocket）

> 这是 OpenClaw 官方文档里特别强调的一步：**Feishu 建议使用长连接（WebSocket）收事件，这样不需要公网 webhook。**
>
> 另外还有一个容易踩坑的点：**在飞书后台配置长连接事件前，OpenClaw 侧最好已经完成 Feishu 渠道配置，并确保网关正在运行。否则长连接配置可能保存失败。**

### 操作位置

- 飞书开放平台 → **事件订阅 / Event Subscription**

### 操作步骤

1. 选择 **使用长连接接收事件（WebSocket / long connection）**。
2. 添加事件：

```text
im.message.receive_v1
```

3. 保存。

### 预期结果

事件列表里应出现 `im.message.receive_v1`。

### 常见报错与排查

#### 报错 1：事件订阅保存不了

排查顺序：

1. 先在 OpenClaw 里把 Feishu 渠道配置好。
2. 确认 OpenClaw 网关已在运行：

```bash
openclaw gateway status
```

3. 再回飞书后台保存一次。

#### 报错 2：机器人完全收不到消息

重点检查下面 6 项：

1. 应用是否已经发布
2. 是否已添加 `im.message.receive_v1`
3. 是否选择的是**长连接**而不是别的模式
4. 权限是否配置完整
5. OpenClaw 网关是否在运行
6. OpenClaw 日志里是否有报错

查看日志命令：

```bash
openclaw logs --follow
```

---

## 6.5 发布应用

### 操作位置

- 飞书开放平台 → **版本管理与发布 / Version Management & Release**

### 操作步骤

1. 创建新版本。
2. 提交审核 / 发布。
3. 等待企业管理员批准（很多企业自建应用会较快通过）。

### 预期结果

应用状态显示为已发布、可用。

### 常见报错与排查

#### 报错：配置都对，但机器人仍不响应

很大概率是 **应用没发布**，这是最常见漏项之一。

---

## 6.6 把飞书凭据配置到 OpenClaw

### 路线 A：CLI 交互式添加（推荐）

在终端执行：

```bash
openclaw channels add
```

然后：

1. 选择 **Feishu**
2. 填入 `YOUR_FEISHU_APP_ID`
3. 填入 `YOUR_FEISHU_APP_SECRET`

完成后执行：

```bash
openclaw gateway restart
openclaw gateway status
```

### 路线 B：手动编辑配置文件

编辑 `~/.openclaw/openclaw.json`，加入如下配置：

```json5
{
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "pairing",
      accounts: {
        main: {
          appId: "YOUR_FEISHU_APP_ID",
          appSecret: "YOUR_FEISHU_APP_SECRET",
          botName: "OpenClaw 助手",
        },
      },
    },
  },
}
```

如果你使用的是国际版 Lark，需要再加上：

```json5
{
  channels: {
    feishu: {
      domain: "lark",
    },
  },
}
```

保存后执行：

```bash
openclaw gateway restart
openclaw gateway status
```

### 预期结果

- 网关状态正常
- 日志里不再出现 Feishu 鉴权错误
- 飞书用户给 Bot 发私聊时，OpenClaw 能收到事件

### 常见报错与排查

#### 报错 1：配置了 App ID / Secret，但机器人不回消息

排查顺序：

1. 检查 App ID、App Secret 是否粘贴错。
2. 检查应用是否已发布。
3. 检查权限是否完整。
4. 检查事件订阅是否是 `im.message.receive_v1`。
5. 检查日志：

```bash
openclaw logs --follow
```

#### 报错 2：Webhook Token 不知道填哪里

如果你按本文推荐的 **长连接 WebSocket** 方式接入，通常**不需要**额外配置 `verificationToken`。

只有你改成 `connectionMode: "webhook"` 时，才需要在飞书后台复制 Verification Token，并配置到：

```text
channels.feishu.verificationToken
```

---

# 七、步骤 5：打通“飞书 Bot ↔ OpenClaw”全链路并完成验收

> 到这里为止，你的 MiniMax 和飞书理论上都已经接入了。下面要做的是最后的闭环验收。

## 7.1 先做 OpenClaw 侧基础检查

### 在终端执行

```bash
openclaw gateway status
openclaw models list
```

### 你要看什么

1. 网关状态正常
2. 模型列表里有：

```text
minimax/MiniMax-M2.5
```

3. 如果没有，就先回去检查第五章

---

## 7.2 在飞书里给 Bot 发第一条私聊

### 操作位置

- 飞书客户端

### 操作步骤

1. 搜索你刚创建并发布的 Bot。
2. 打开私聊窗口。
3. 发送一句最简单的话，例如：

```text
你好
```

### 预期结果

因为 OpenClaw 官方文档默认建议 Feishu 直聊使用：

```text
dmPolicy: "pairing"
```

所以第一次私聊时，机器人通常不会直接进入正常对话，而是先返回一个 **pairing code（配对码）**。

### 常见报错与排查

#### 报错：发消息后毫无反应

排查顺序：

1. 看应用是否已发布
2. 看事件订阅是否正确
3. 看网关是否运行
4. 看日志是否有错误

```bash
openclaw logs --follow
```

---

## 7.3 批准 pairing（配对）

### 操作位置

- OpenClaw 终端 / SSH

### 操作步骤

先查看待批准请求：

```bash
openclaw pairing list feishu
```

然后批准配对码：

```bash
openclaw pairing approve feishu YOUR_FEISHU_PAIRING_CODE
```

### 预期结果

批准成功后，这个飞书账号就被允许和机器人正常私聊了。

### 常见报错与排查

#### 报错 1：配对码无效

排查顺序：

1. 检查是否复制错字符。
2. 注意配对码通常是大写、8 位、且会过期。
3. 如果过期，让用户重新给 Bot 发一条私聊，拿新 code。

#### 报错 2：`pairing list` 看不到请求

排查顺序：

1. 先确认飞书那边确实已经给 Bot 发过消息。
2. 确认 Feishu 渠道配置的是同一套 App ID / Secret。
3. 确认网关在消息到达时处于运行状态。

---

## 7.4 做正式验收

### 验收动作 A：查看状态

在飞书里发：

```text
/status
```

### 预期结果

Bot 能返回当前状态信息。

### 验收动作 B：做自然语言对话

在飞书里发：

```text
请用一句话介绍你自己
```

### 预期结果

Bot 能正常回复，说明消息接收、模型调用、消息发送链路都通了。

### 验收动作 C：查看日志

终端执行：

```bash
openclaw logs --follow
```

### 预期结果

日志里不应持续出现：

- Feishu 鉴权失败
- MiniMax 鉴权失败
- 模型不存在
- 消息发送失败

---

## 7.5 可选：群聊验收

如果你还想让机器人在群里工作，可以继续做下面这一步。

### 操作位置

- 飞书群聊
- OpenClaw 配置文件

### 推荐做法

先使用默认安全策略：

- 群策略先保持默认
- 在群里通过 **@机器人** 触发
- 不要一开始就设置成“所有群都自动回复”

根据 OpenClaw 文档，Feishu 群聊常见控制项包括：

- `groupPolicy`
- `groupAllowFrom`
- `groups.<chat_id>.requireMention`

### 最稳妥的群聊验收方法

1. 把 Bot 拉进一个测试群
2. 在群里 @Bot 并发送一句话
3. 观察它是否只在被 @ 时回复

---

# 八、推荐的一份最小可用配置示例（MiniMax + Feishu）

> 如果你想要一眼看懂“最小闭环长什么样”，下面这份可以作为参考。请把敏感内容替换成你自己的占位值。

```json5
{
  env: {
    MINIMAX_API_KEY: "YOUR_MINIMAX_API_KEY",
  },
  agents: {
    defaults: {
      models: {
        "minimax/MiniMax-M2.5": { alias: "minimax" },
      },
      model: {
        primary: "minimax/MiniMax-M2.5",
      },
    },
  },
  models: {
    mode: "merge",
    providers: {
      minimax: {
        baseUrl: "https://api.minimax.io/anthropic",
        apiKey: "${MINIMAX_API_KEY}",
        api: "anthropic-messages",
        models: [
          {
            id: "MiniMax-M2.5",
            name: "MiniMax M2.5",
            reasoning: true,
            input: ["text"],
            cost: { input: 0.3, output: 1.2, cacheRead: 0.03, cacheWrite: 0.12 },
            contextWindow: 200000,
            maxTokens: 8192,
          },
        ],
      },
    },
  },
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "pairing",
      accounts: {
        main: {
          appId: "YOUR_FEISHU_APP_ID",
          appSecret: "YOUR_FEISHU_APP_SECRET",
          botName: "OpenClaw 助手",
        },
      },
    },
  },
}
```

---

# 九、上线后安全建议（很重要）

## 9.1 不要一开始就把 DM 政策设成完全开放

OpenClaw 官方文档对 Feishu 默认推荐的是：

```text
dmPolicy: "pairing"
```

这个默认值是合理的，建议保留。这样陌生人第一次私聊机器人时，不会直接拿到能力，而是要先配对批准。

## 9.2 优先使用 pairing 或 allowlist，而不是 open

如果是个人助手或家庭助手，建议优先：

- `pairing`
- 或 `allowlist`

不建议一上来就：

- `open`

## 9.3 群聊一定要先小范围测试

建议顺序：

1. 先只开私聊
2. 再开一个测试群
3. 再决定是否放到正式群

## 9.4 密钥泄露后的处理顺序

如果怀疑泄露：

1. 去 MiniMax 控制台重置 API Key
2. 去飞书开放平台重置 App Secret
3. 更新 OpenClaw 配置
4. 重启网关
5. 用飞书重新做一次验收

## 9.5 日志可看，但不要把日志公开外发

`openclaw logs --follow` 对排障很有用，但日志里可能包含：

- 账号标识
- 配对信息
- 调用错误细节

所以日志适合自己排查，不适合随手公开发群。

## 9.6 非必要不要暴露公网

本文推荐的是飞书 **长连接 WebSocket** 方案，优点就是：

- 不需要自己额外暴露公网 webhook
- 更适合家庭 NAS / 内网部署

如果你后面真的要开放远程访问，请务必确认：

- 网关认证已开启
- 不使用默认弱口令
- 不随意开放到 `0.0.0.0` 且无鉴权

---

# 十、最常见问题速查

## 10.1 飞书 Bot 完全没反应

优先检查这 5 项：

1. 应用已发布
2. 已开 Bot 能力
3. 已加 `im.message.receive_v1`
4. OpenClaw 网关在运行
5. `openclaw logs --follow` 无致命错误

## 10.2 MiniMax 配好了，但模型列表没有 M2.5

优先检查这 4 项：

1. `MINIMAX_API_KEY` 是否存在
2. `models.providers.minimax` 是否写对
3. 模型 ID 是否大小写正确
4. 是否执行过 `openclaw gateway restart`

## 10.3 收到 pairing code 但批准失败

优先检查：

1. code 是否已过期
2. 是否复制错字符
3. 是否批准了错误的渠道（必须是 `feishu`）

正确命令：

```bash
openclaw pairing approve feishu YOUR_FEISHU_PAIRING_CODE
```

## 10.4 机器人能收消息但发不回去

优先检查：

- 飞书权限 `im:message:send_as_bot`
- 应用是否已发布
- 日志里是否有发送失败原因

---

# 十一、最终验收清单

请你按下面顺序逐项打勾：

- [ ] 极空间已安装并运行 OpenClaw 官方 App
- [ ] `openclaw gateway status` 正常
- [ ] 已拿到 `YOUR_MINIMAX_API_KEY`
- [ ] `openclaw models list` 能看到 `minimax/MiniMax-M2.5`
- [ ] 已创建飞书企业自建应用
- [ ] 已拿到 `YOUR_FEISHU_APP_ID` 和 `YOUR_FEISHU_APP_SECRET`
- [ ] 已配置权限并开启 Bot 能力
- [ ] 已添加事件 `im.message.receive_v1`
- [ ] 飞书应用已发布
- [ ] 首次私聊已收到 pairing code
- [ ] 已执行 `openclaw pairing approve feishu YOUR_FEISHU_PAIRING_CODE`
- [ ] 飞书里发送 `/status` 能正常返回
- [ ] 飞书里发送普通问题，Bot 能正常回复

当上面全部打勾，就说明你的“飞书 Bot ↔ OpenClaw ↔ MiniMax”链路已经完整打通啦。

---

# 十二、建议你保存的 4 条常用命令

```bash
openclaw gateway status
openclaw gateway restart
openclaw logs --follow
openclaw pairing list feishu
```

如果你只记住这 4 条命令，后续排障已经够用一大半了。

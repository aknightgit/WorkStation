# 🀄 联机麻将游戏

## 项目简介
- 实时联机多人对战麻将游戏
- 支持自定义规则
- 跨平台 (Android + iOS)

## 技术栈
- **客户端**: Flutter
- **后端**: Python FastAPI + WebSocket
- **数据库**: MariaDB

## 项目结构
```
mahjong-game/
├── lib/               # Flutter源码
│   ├── core/          # 核心配置
│   ├── models/       # 数据模型
│   ├── screens/      # 页面
│   ├── widgets/      # 组件
│   ├── utils/        # 工具类
│   └── game_logic/  # 游戏逻辑
├── assets/            # 资源文件
│   ├── images/       # 图片素材
│   ├── sounds/       # 音效
│   └── backgrounds/  # 背景图
└── res/              # 配置文件
```

## 开发流程 (K哥提需求 → 小虾米开发)

### 需求管理
```
docs/
├── 需求文档/          ← K哥更新规则
│   ├── 基础规则.md
│   └── 玩法规则.md
└── 功能模块/          ← K哥更新功能需求
    └── 模块列表.md
```

### 交互方式
1. **K哥** 更新 `docs/需求文档/` 或 `docs/功能模块/`
2. **小虾米** 定期查看差异，开始开发迭代

---

## 开发进度
- [ ] Step 1: 基础框架 + 牌面UI
- [ ] Step 2: 本地对战
- [ ] Step 3: 联机框架
- [ ] Step 4: 规则引擎
- [ ] Step 5: 用户系统
- [ ] Step 6: 打包发布

## 运行
```bash
flutter pub get
flutter run
```

# Ego - AI时代的自我认知社交平台

> **核心理念**: 人是社会关系的总和 × AI赋能的深度自我认知

Ego是一个创新的社交应用，让用户通过AI深度认识自己，发现"异类"之处的共鸣者，并真正拥有自己的数据资产。

---

## ✨ 核心功能

### 1. 快速性格测试
- 趣味化问题设计（类似小红书黑暗人格测试）
- 无观察者效应，真实反映用户特质
- AI实时分析，生成个性化画像

### 2. 个人画像系统
- **关键事件记录**: 人生重要时刻
- **擅长/喜好/癖好**: 多维度自我描述
- **三级隐私控制**:
  - 🔒 完全私密（只有AI知道）
  - 🌓 半公开（匿名匹配）
  - 🌞 裸奔模式（Feed流公开）

### 3. 双瀑布流Feed（首页）
- Instagram式双列瀑布流
- 智能推荐算法
- **"异类共鸣"发现**: 找到相似的"怪人"
- 点赞互动："有点东西"

### 4. RAG Agent（AI数字分身）
- 基于用户画像的个性化Agent
- 深度自我洞察生成
- **关系预测**: "你可能与这类人产生连接"
- **共鸣发现**: "有247人和你一样"

### 5. Web3数据主权
- 数据资产NFT化
- 去中心化存储（IPFS/Arweave）
- 用户从数据中获益（$EGO代币）
- 区块链确保所有权

---

## 🏗️ 技术架构

### 前端 (iOS)
```
SwiftUI
├── Views/          # UI层
├── ViewModels/     # MVVM模式
├── Models/         # 数据模型
├── Services/       # 网络、认证、业务逻辑
└── Utils/          # 工具类
```

**技术栈**:
- SwiftUI + Combine
- Core Data (本地缓存)
- WalletConnect (Web3钱包)

### 后端 (Python FastAPI)
```
Backend/
├── app/
│   ├── api/v1/        # API路由
│   ├── core/          # 配置、数据库
│   ├── models/        # 数据模型
│   ├── services/      # 业务逻辑
│   │   └── rag_agent.py   # RAG核心
│   └── utils/         # 工具
└── main.py
```

**技术栈**:
- FastAPI (异步API)
- SQLAlchemy + AsyncPG (PostgreSQL)
- Motor (MongoDB异步驱动)
- Pinecone/Qdrant (向量数据库)
- Anthropic Claude API (AI能力)
- LangChain (RAG框架)

### 智能合约 (Solidity)
```
Contracts/
├── EgoDataAsset.sol   # 数据资产NFT
├── EgoToken.sol       # $EGO代币
└── deploy/            # 部署脚本
```

**部署链**: Polygon (低gas费)

### 数据库架构
- **PostgreSQL**: 用户、认证、交易
- **MongoDB**: 用户画像、事件、洞察
- **Pinecone**: 向量检索（RAG）
- **Redis**: 缓存、会话

---

## 🚀 快速开始

### 前置要求
- **iOS开发**: Xcode 15+, iOS 17+
- **后端开发**: Python 3.11+, Node.js 18+
- **数据库**: PostgreSQL 15+, MongoDB 6+, Redis 7+
- **区块链**: Hardhat, MetaMask

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/ego-app.git
cd ego-app
```

### 2. 后端设置

#### 安装依赖
```bash
cd EgoApp/Backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### 配置环境变量
```bash
cp .env.example .env
```

编辑 `.env`:
```env
# 数据库
DATABASE_URL=postgresql+asyncpg://ego:password@localhost/ego_db
MONGODB_URL=mongodb://localhost:27017
REDIS_URL=redis://localhost:6379

# AI
ANTHROPIC_API_KEY=your_claude_api_key
OPENAI_API_KEY=your_openai_api_key

# 向量数据库
PINECONE_API_KEY=your_pinecone_key
PINECONE_ENVIRONMENT=us-west1-gcp

# Web3
WEB3_PROVIDER_URL=https://polygon-mumbai.infura.io/v3/YOUR_KEY

# JWT
SECRET_KEY=your_super_secret_key_change_in_production
```

#### 初始化数据库
```bash
# PostgreSQL
createdb ego_db
alembic upgrade head

# MongoDB
python scripts/init_mongodb.py

# Pinecone
python scripts/init_vector_db.py
```

#### 启动后端
```bash
uvicorn main:app --reload --port 8000
```

访问: `http://localhost:8000/api/docs`

### 3. iOS App设置

#### 打开Xcode项目
```bash
cd EgoApp/iOS
open Ego.xcodeproj
```

#### 配置API端点
编辑 `Services/APIClient.swift`:
```swift
init(baseURL: String = "http://localhost:8000") {
    // 修改为你的后端地址
}
```

#### 运行App
1. 选择模拟器或真机
2. Cmd + R 运行

### 4. 智能合约部署

#### 安装依赖
```bash
cd EgoApp/Contracts
npm install
```

#### 配置Hardhat
编辑 `hardhat.config.js`:
```javascript
module.exports = {
  networks: {
    polygonMumbai: {
      url: "https://polygon-mumbai.infura.io/v3/YOUR_KEY",
      accounts: [PRIVATE_KEY]
    }
  }
};
```

#### 部署合约
```bash
# 部署到测试网
npx hardhat run scripts/deploy.js --network polygonMumbai

# 验证合约
npx hardhat verify --network polygonMumbai CONTRACT_ADDRESS
```

---

## 📖 核心流程

### 用户注册流程
```
1. 下载App → 连接钱包/邮箱注册
2. 完成快速性格测试（10分钟）
3. AI生成初始画像
4. 铸造数据资产NFT
5. 引导添加第一个关键事件
6. 进入双瀑布流Feed
```

### RAG Agent工作流程
```
用户提问
    ↓
向量化问题
    ↓
在向量数据库中检索相关用户数据（Top 5）
    ↓
构建上下文（事件、技能、兴趣、癖好）
    ↓
调用Claude API生成回答
    ↓
返回个性化洞察
```

### 推荐算法流程
```
获取用户画像向量
    ↓
语义相似度匹配（余弦相似度）
    ↓
"异类共鸣"发现（低频标签高匹配）
    ↓
多样性保证（避免信息茧房）
    ↓
混合排序（相似度 × 新鲜度 × 多样性）
    ↓
返回Feed内容
```

### 数据资产收益流程
```
用户数据被使用（匹配、推荐）
    ↓
触发智能合约 recordAccess()
    ↓
计算奖励（基于使用次数和质量）
    ↓
铸造$EGO代币
    ↓
自动分配给数据所有者
```

---

## 🎨 UI/UX设计原则

### 视觉风格
- **配色**: 紫色主色调 + 深色模式优先
- **字体**: SF Pro (iOS默认)
- **圆角**: 16px（卡片）、20px（按钮）
- **阴影**: 轻柔的投影（opacity 0.05-0.1）

### 交互设计
- **微动画**: 点赞、加载等使用spring动画
- **反馈**: 触觉反馈（Haptic Feedback）
- **手势**: 支持左滑/右滑快速操作

### 信息架构
```
Tab Bar (4个Tab)
├── 发现 (Feed)      # 首页，双瀑布流
├── 灵魂 (Agent)     # AI分身对话
├── 我 (Profile)     # 个人画像
└── 资产 (Wallet)    # Web3钱包
```

---

## 🔐 隐私与安全

### 数据加密
- **传输**: HTTPS/TLS 1.3
- **存储**:
  - 密码: bcrypt (cost factor 12)
  - 敏感数据: AES-256-GCM
  - 钱包私钥: iOS Keychain

### 隐私分层
```
完全私密 (Private)
├── 只存储在用户设备 + 加密云备份
├── AI分析时临时解密（阅后即焚）
└── 向量化后用于匹配（不保留原文）

半公开 (Semi)
├── 匿名化后用于匹配
└── 不在Feed流展示

裸奔模式 (Public)
├── 在Feed流公开展示
└── 可收获点赞和评论
```

### 合规性
- **GDPR**: 数据导出、删除权
- **CCPA**: 加州隐私法合规
- **未成年人保护**: 年龄验证（18+）

---

## 🌐 API文档

### 认证
```http
POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/auth/me
```

### 用户画像
```http
GET    /api/v1/profile
POST   /api/v1/profile/events
PUT    /api/v1/profile/personality
POST   /api/v1/profile/skills
POST   /api/v1/profile/interests
POST   /api/v1/profile/quirks
```

### Feed流
```http
GET  /api/v1/feed?page=0&pageSize=20
GET  /api/v1/feed/daily-stats
POST /api/v1/events/{id}/like
POST /api/v1/events/{id}/comments
```

### AI Agent
```http
GET  /api/v1/agent
POST /api/v1/agent/query
GET  /api/v1/agent/insights
GET  /api/v1/agent/predictions
GET  /api/v1/agent/similar-souls
```

### Web3
```http
POST /api/v1/web3/mint-data-asset
GET  /api/v1/web3/transactions
POST /api/v1/web3/withdraw
```

完整API文档: `http://localhost:8000/api/docs`

---

## 🧪 测试

### 后端测试
```bash
cd EgoApp/Backend
pytest tests/ -v --cov=app
```

### iOS测试
```bash
# 单元测试
xcodebuild test -scheme Ego -destination 'platform=iOS Simulator,name=iPhone 15'

# UI测试
xcodebuild test -scheme EgoUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 智能合约测试
```bash
cd EgoApp/Contracts
npx hardhat test
npx hardhat coverage
```

---

## 📊 性能指标

### 目标性能
- API响应时间: < 100ms (P95)
- RAG查询延迟: < 500ms (P95)
- Feed加载时间: < 300ms
- 向量检索: < 50ms

### 监控
- **后端**: Datadog / Prometheus
- **前端**: Firebase Performance
- **数据库**: pgAnalyze (PostgreSQL)
- **区块链**: Etherscan API

---

## 🛣️ Roadmap

### MVP (3个月)
- [x] 基础架构搭建
- [x] iOS UI框架
- [x] 后端API
- [ ] 性格测试系统
- [ ] 基础Feed流
- [ ] 简单AI分析

### v1.0 (6个月)
- [ ] RAG Agent完整功能
- [ ] 推荐算法v1
- [ ] Web3集成
- [ ] 内测发布

### v2.0 (12个月)
- [ ] Android版本
- [ ] 匿名社交功能
- [ ] 数据市场（用户可出售匿名洞察）
- [ ] DAO治理

---

## 💡 常见问题

### Q: 数据真的归用户所有吗？
A: 是的。通过NFT和去中心化存储，用户拥有数据的完全控制权。即使平台关闭，数据依然存在于IPFS/Arweave上。

### Q: AI如何保护隐私？
A: 私密数据只在分析时临时解密，结果不包含原始内容。匹配使用向量相似度，不暴露明文。

### Q: 如何获得$EGO代币？
A: 通过以下方式:
1. 数据被匹配算法使用
2. 裸奔内容获得高点赞
3. 帮助他人获得洞察
4. 长期活跃用户奖励

### Q: 性格测试准确吗？
A: 测试基于心理学研究（Big Five, Dark Triad），但更注重趣味性和自我探索，而非严格的学术标准。

---

## 🤝 贡献

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)

### 开发流程
1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

---

## 📄 License

本项目采用 MIT License - 详见 [LICENSE](LICENSE)

---

## 📞 联系我们

- **Email**: hello@ego.app
- **Twitter**: [@EgoApp](https://twitter.com/EgoApp)
- **Discord**: [加入社区](https://discord.gg/ego)

---

## 🙏 致谢

- **AI**: Anthropic Claude, OpenAI
- **向量数据库**: Pinecone
- **区块链**: Polygon, IPFS
- **灵感**: 小红书, Instagram, Mirror

---

**Built with ❤️ by the Ego Team**

*让每个人都能成为自己，并因此获益*

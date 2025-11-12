# Ego App - 完整架构设计文档

## 📱 项目概述

**App名称**: Ego
**核心理念**: 人是社会关系的总和 - AI时代的自我认知与社交连接
**目标**: 让用户通过AI深度认识自己，发现"异类"之处的共鸣，实现数据主权和收益

---

## 🏗️ 系统架构

### 1. 前端层 (iOS App)
```
SwiftUI + Combine
├── 认证模块 (Web3 Wallet)
├── 性格测试模块
├── 个人画像模块
├── 双瀑布流Feed
├── RAG Agent可视化
└── 数据资产管理
```

### 2. 后端层
```
Microservices Architecture
├── API Gateway (GraphQL/REST)
├── User Service (认证、画像管理)
├── Content Service (事件、Feed推荐)
├── AI Service (RAG Agent、分析引擎)
├── Blockchain Service (Web3集成)
└── Matching Service (关系预测)
```

### 3. AI层
```
├── Personality Analysis (性格测试分析)
├── RAG Agent System (基于向量数据库)
├── Recommendation Engine (Feed推荐算法)
└── Similarity Matching (发现相似用户)
```

### 4. Web3层
```
├── Smart Contracts (数据所有权NFT)
├── Decentralized Storage (IPFS/Arweave)
├── Token Economy (数据收益分配)
└── Wallet Integration
```

---

## 🎨 核心功能模块

### Module 1: 快速性格测试
**特点**: 类似小红书黑暗人格测试，无观察者效应

**流程**:
1. 用户进入测试（首次注册必须完成）
2. 10-15道趣味化问题
3. AI实时分析，生成初始画像
4. 可视化结果展示（雷达图/标签云）

**数据结构**:
```typescript
interface PersonalityTest {
  id: string
  userId: string
  answers: Answer[]
  traits: Trait[]  // 黑暗三元素、五大人格等
  timestamp: Date
  isPublic: boolean  // 是否裸奔
}
```

### Module 2: 个人画像系统
**隐私层级**:
- 🔒 **完全私密** (只有用户和AI知道)
- 🌓 **半公开** (用于匿名匹配)
- 🌞 **裸奔模式** (Feed流展示)

**内容类型**:
```typescript
interface UserProfile {
  userId: string
  keyEvents: Event[]        // 关键事件
  skills: Skill[]           // 擅长
  interests: Interest[]     // 喜好
  quirks: Quirk[]          // 癖好
  embedding: number[]       // 向量化表示(RAG)
  nftTokenId?: string      // Web3数据资产
}

interface Event {
  id: string
  title: string
  description: string
  emotionalImpact: number  // 情感影响值
  privacyLevel: 'private' | 'semi' | 'public'
  tags: string[]
  timestamp: Date
  likes?: number  // 裸奔模式下的"有点东西"数
}
```

### Module 3: 双瀑布流Feed (首页)
**设计**: Instagram式双列瀑布流

**推荐算法**:
1. 基于用户兴趣向量匹配
2. "异类共鸣"发现（反常识推荐）
3. 热度衰减 (时间因子)
4. 多样性保证 (避免信息茧房)

**交互**:
- 点赞："有点东西"按钮
- 评论：匿名共鸣
- 收藏：加入自己的思考库

**伪代码**:
```python
def recommend_feed(user_profile):
    # 1. 获取用户向量
    user_vector = user_profile.embedding

    # 2. 语义相似度匹配
    similar_events = vector_db.similarity_search(
        user_vector,
        top_k=100,
        filters={"privacyLevel": "public"}
    )

    # 3. "异类共鸣"发现（低频标签高匹配）
    quirky_matches = find_uncommon_similarities(user_profile)

    # 4. 混合排序
    feed = blend_and_rank(similar_events, quirky_matches)

    return feed[:20]  # 每次加载20条
```

### Module 4: RAG Agent系统
**核心概念**: 用户的数字分身，代替用户产生社会关系

**Agent能力**:
1. **关系预测**: "你可能与这类人产生连接"
2. **共鸣发现**: "有247人和你一样喜欢午夜独自散步"
3. **自我洞察**: "你的数据显示，你在创造性工作时最有活力"

**技术实现**:
```typescript
interface UserAgent {
  userId: string
  knowledgeBase: VectorStore  // 用户所有数据的向量库
  personality: PersonalityProfile
  relationshipPredictions: Prediction[]

  // 方法
  findSimilarSouls(): User[]
  predictConnections(): ConnectionPrediction[]
  generateInsights(): Insight[]
}

// RAG检索流程
async function agentQuery(question: string, userId: string) {
  // 1. 检索相关上下文
  const context = await vectorDB.retrieve({
    query: question,
    userId: userId,
    topK: 5
  })

  // 2. 调用AI生成回答
  const response = await ai.generate({
    system: "你是用户的AI分身，了解他们的所有经历",
    context: context,
    question: question
  })

  return response
}
```

**关系预测算法**:
```python
def predict_connections(user_agent):
    # 基于用户画像生成理想连接画像
    ideal_traits = analyze_complementary_traits(user_agent)

    # 在全局用户池中查找匹配
    potential_matches = match_users(ideal_traits, min_score=0.7)

    # 生成洞察
    insights = [
        f"你可能与【{match.archetype}】类型的人有{match.score*100}%共鸣",
        f"你们共同的异类特质：{match.common_quirks}"
    ]

    return {
        "matches": potential_matches,
        "insights": insights
    }
```

### Module 5: Web3去中心化架构
**数据主权方案**:

#### 5.1 数据存储
```
用户数据 = 链上元数据 + 链下加密存储

链上 (Blockchain):
- 数据所有权NFT
- 访问权限记录
- 收益分配智能合约

链下 (IPFS/Arweave):
- 加密的个人画像数据
- 事件内容
- AI分析结果
```

#### 5.2 智能合约设计
```solidity
// 数据资产NFT
contract EgoDataAsset {
    struct UserData {
        address owner;
        string ipfsHash;      // 加密数据的IPFS地址
        uint256 accessCount;  // 被访问次数
        uint256 earnings;     // 累计收益
    }

    mapping(address => UserData) public userAssets;

    // 铸造数据资产NFT
    function mintDataAsset(string memory ipfsHash) external {
        require(userAssets[msg.sender].owner == address(0), "Already minted");
        userAssets[msg.sender] = UserData(msg.sender, ipfsHash, 0, 0);
    }

    // 授权访问（如AI分析、匹配服务）
    function grantAccess(address service) external {
        // 记录访问，触发收益
        userAssets[msg.sender].accessCount++;
        // 分配代币奖励
        distributeReward(msg.sender);
    }
}
```

#### 5.3 收益模型
```
用户获益方式:
1. 数据被匹配算法使用 → 获得$EGO代币
2. 裸奔内容获得高点赞 → 创作者奖励
3. 帮助他人获得洞察 → 贡献者分成
4. 长期活跃用户 → 持有份额分红
```

---

## 🔄 用户旅程

### 首次使用
```
1. 下载App → 连接Web3钱包（可选邮箱注册）
2. 完成快速性格测试（10分钟）
3. AI生成初始画像 → 铸造数据资产NFT
4. 引导添加第一个关键事件
5. 进入双瀑布流Feed → 发现共鸣
```

### 日常使用
```
打开App → 首页双瀑布流
↓
刷到共鸣内容 → 点"有点东西"
↓
查看自己的Agent洞察 → "今日发现3个灵魂相似者"
↓
选择性添加新事件/更新画像
↓
查看数据资产收益
```

### 深度探索
```
进入Agent页面
↓
提问："我这种性格适合什么工作？"
↓
RAG检索 + AI分析 → 个性化回答
↓
查看关系预测 → "你可能与[创意工作者]产生连接"
↓
匿名匹配 → 发现志同道合者
```

---

## 🛡️ 隐私与安全

### 加密策略
```
三层加密:
1. 端到端加密（用户设备 ↔ IPFS）
2. 钱包私钥控制数据访问权
3. 零知识证明（匹配时不暴露原始数据）
```

### 数据流转
```
私密数据路径:
用户输入 → 本地加密 → IPFS存储 → 仅向量化后用于匹配
         ↓
      AI分析（临时解密，阅后即焚）
         ↓
      生成洞察（不含原始内容）
```

### 合规性
- 符合GDPR（用户拥有删除权）
- 内容审核（裸奔模式需过滤违规）
- 未成年人保护（年龄验证）

---

## 📊 技术栈

### iOS Frontend
- **UI**: SwiftUI
- **状态管理**: Combine + SwiftUI Environment
- **网络**: Alamofire / URLSession
- **Web3**: WalletConnectSwift / Web3.swift
- **数据库**: Core Data + CloudKit (本地缓存)

### Backend
- **API**: Node.js (Express) / Python (FastAPI)
- **数据库**: PostgreSQL (结构化) + MongoDB (文档)
- **向量数据库**: Pinecone / Weaviate / Qdrant
- **缓存**: Redis
- **消息队列**: RabbitMQ (异步AI分析)

### AI Infrastructure
- **LLM**: Claude API / OpenAI GPT-4
- **Embeddings**: OpenAI text-embedding-3 / Cohere
- **RAG框架**: LangChain / LlamaIndex

### Web3
- **链**: Polygon (低gas费) / Base
- **存储**: IPFS (Pinata) + Arweave (永久存储)
- **合约**: Solidity + Hardhat
- **钱包**: WalletConnect

### DevOps
- **容器**: Docker + Kubernetes
- **CI/CD**: GitHub Actions
- **监控**: Datadog / Sentry

---

## 🚀 MVP开发路线图

### Phase 1: 核心功能 (3个月)
- [ ] iOS基础UI框架
- [ ] 性格测试系统
- [ ] 个人画像CRUD
- [ ] 简单Feed流（无推荐算法）
- [ ] 基础AI分析（调用Claude API）

### Phase 2: AI增强 (2个月)
- [ ] RAG Agent系统
- [ ] 向量数据库集成
- [ ] 推荐算法v1
- [ ] 关系预测功能

### Phase 3: Web3集成 (2个月)
- [ ] 钱包连接
- [ ] 智能合约部署
- [ ] IPFS存储
- [ ] 数据资产NFT

### Phase 4: 社交优化 (1个月)
- [ ] 匿名匹配
- [ ] 共鸣社区
- [ ] 收益分配
- [ ] 内容审核

---

## 💡 创新点

1. **反观察者效应测试**: 趣味化、去社会期待的性格测试
2. **异类共鸣**: 不是找相似者，而是找"同样怪"的人
3. **AI数字分身**: Agent代替用户建立关系预测
4. **数据主权**: 用户真正拥有并从数据获益
5. **隐私裸奔**: 可选择性暴露，控制权在用户

---

## 🎯 商业模式

### 免费版
- 基础性格测试
- 有限的事件存储(10条)
- Feed浏览
- 基础AI洞察(每天3次)

### Pro版 ($9.99/月)
- 无限事件存储
- 高级AI分析
- 优先匹配
- 数据导出

### 平台收益
- Pro订阅分成(70%给用户数据贡献,30%平台)
- 裸奔内容打赏抽成(10%)
- 企业级API(匿名化洞察数据)

---

## 📝 下一步行动

1. **立即开始**: 创建iOS项目骨架
2. **准备素材**: 性格测试题库
3. **设计UI**: Figma原型
4. **技术验证**: RAG系统POC
5. **智能合约**: 编写测试合约

---

**文档版本**: v1.0
**最后更新**: 2025-11-12
**作者**: Claude + Denix

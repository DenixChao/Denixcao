# Ego App - 数据库设计

## 架构概览

Ego App采用混合数据库架构：
- **PostgreSQL**: 结构化数据（用户、认证）
- **MongoDB**: 灵活的文档数据（用户画像、事件）
- **Pinecone/Qdrant**: 向量数据库（RAG检索）
- **Redis**: 缓存和会话

---

## PostgreSQL Schema

### 1. Users表（核心用户信息）

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,  -- bcrypt hash

    -- Web3
    wallet_address VARCHAR(42) UNIQUE,  -- Ethereum address
    nft_token_id VARCHAR(100),          -- 数据资产NFT ID

    -- 状态
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,

    -- 统计
    total_events INTEGER DEFAULT 0,
    public_events INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    matched_souls INTEGER DEFAULT 0,
    data_asset_value DECIMAL(18, 8) DEFAULT 0,  -- $EGO代币

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,

    -- 索引
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_wallet ON users(wallet_address);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### 2. Sessions表（会话管理）

```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- 设备信息
    device_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);
```

### 3. Transactions表（代币交易记录）

```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),

    -- 交易信息
    type VARCHAR(50) NOT NULL,  -- 'data_access', 'content_like', 'withdraw', etc.
    amount DECIMAL(18, 8) NOT NULL,
    balance_after DECIMAL(18, 8) NOT NULL,

    -- 区块链信息
    tx_hash VARCHAR(66),  -- Ethereum transaction hash
    block_number BIGINT,

    -- 元数据
    metadata JSONB,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
```

---

## MongoDB Collections

### 1. user_profiles（用户画像）

```javascript
{
  _id: ObjectId,
  user_id: String,  // 对应PostgreSQL的user.id

  // 性格测试结果
  personality_traits: [
    {
      id: String,
      name: String,  // "黑暗三元素-自恋"
      score: Number,  // 0-100
      category: String,  // "darkTriad", "bigFive", "custom"
      is_public: Boolean,
      tested_at: Date
    }
  ],

  // 关键事件
  key_events: [
    {
      id: String,
      title: String,
      description: String,
      emotional_impact: Number,  // -10 to +10
      privacy_level: String,  // "private", "semi", "public"
      tags: [String],
      timestamp: Date,

      // 社交数据（裸奔模式）
      likes: Number,
      comments: [
        {
          id: String,
          user_id: String,
          content: String,
          timestamp: Date,
          is_anonymous: Boolean
        }
      ],

      created_at: Date
    }
  ],

  // 技能
  skills: [
    {
      id: String,
      name: String,
      level: Number,  // 1-10
      verified_by: [String],  // user_ids
      added_at: Date
    }
  ],

  // 兴趣
  interests: [
    {
      id: String,
      name: String,
      intensity: Number,  // 1-10
      category: String,
      added_at: Date
    }
  ],

  // 癖好（高度隐私）
  quirks: [
    {
      id: String,
      description: String,
      tags: [String],
      is_uncommon: Boolean,  // 是否是"异类"特质
      added_at: Date
    }
  ],

  // 向量嵌入（用于RAG）
  embedding: [Number],  // 384维向量
  embedding_version: String,

  // 元数据
  completeness: Number,  // 0-1，画像完整度
  last_updated: Date,
  created_at: Date
}
```

**索引:**
```javascript
db.user_profiles.createIndex({ user_id: 1 }, { unique: true })
db.user_profiles.createIndex({ "key_events.privacy_level": 1 })
db.user_profiles.createIndex({ "key_events.tags": 1 })
db.user_profiles.createIndex({ last_updated: -1 })
```

### 2. agent_conversations（Agent对话历史）

```javascript
{
  _id: ObjectId,
  user_id: String,
  session_id: String,

  messages: [
    {
      id: String,
      role: String,  // "user", "agent", "system"
      content: String,
      timestamp: Date,

      // RAG相关
      retrieved_context: [
        {
          doc_id: String,
          doc_type: String,  // "event", "skill", etc.
          title: String,
          relevance_score: Number
        }
      ]
    }
  ],

  created_at: Date,
  updated_at: Date
}
```

### 3. insights（AI生成的洞察）

```javascript
{
  _id: ObjectId,
  user_id: String,

  type: String,  // "personality", "pattern", "relationship", "growth", "commonality"
  title: String,
  content: String,
  confidence: Number,  // 0-1

  // 支撑数据
  supporting_data: [String],  // 相关事件ID等

  // 状态
  is_read: Boolean,
  is_archived: Boolean,

  generated_at: Date,
  expires_at: Date  // 洞察可能有时效性
}
```

**索引:**
```javascript
db.insights.createIndex({ user_id: 1, generated_at: -1 })
db.insights.createIndex({ user_id: 1, is_read: 1 })
db.insights.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 })  // TTL索引
```

### 4. relationship_predictions（关系预测）

```javascript
{
  _id: ObjectId,
  user_id: String,

  // 预测的人群画像
  archetype: String,  // "深夜创作者", "理性浪漫主义者"
  traits: [String],
  match_score: Number,  // 0-1

  // 共同点
  common_quirks: [String],
  common_interests: [String],

  // AI生成的洞察
  insight: String,

  // 实际匹配到的用户
  matched_users: [
    {
      user_id: String,
      match_score: Number,
      is_anonymous: Boolean
    }
  ],
  matched_users_count: Number,

  generated_at: Date,
  updated_at: Date
}
```

### 5. soul_matches（相似灵魂匹配）

```javascript
{
  _id: ObjectId,
  user_id_1: String,
  user_id_2: String,

  overall_score: Number,  // 0-1

  // 详细匹配维度
  dimensions: [
    {
      name: String,  // "价值观", "兴趣", "异类特质"
      score: Number,
      details: String
    }
  ],

  // 共鸣点
  resonance_points: [
    {
      description: String,  // "你们都喜欢在暴雨中独自散步"
      rarity: Number  // 稀有度，越高越"异类"
    }
  ],

  // 状态
  status: String,  // "pending", "accepted", "hidden"
  is_visible_to_user_1: Boolean,
  is_visible_to_user_2: Boolean,

  discovered_at: Date,
  updated_at: Date
}
```

**索引:**
```javascript
db.soul_matches.createIndex({ user_id_1: 1, overall_score: -1 })
db.soul_matches.createIndex({ user_id_2: 1, overall_score: -1 })
db.soul_matches.createIndex({ overall_score: -1 })
```

---

## Vector Database Schema (Pinecone/Qdrant)

### Index: ego-users

**向量维度**: 384 (使用sentence-transformers/all-MiniLM-L6-v2)

**Metadata结构:**
```json
{
  "user_id": "uuid",
  "doc_id": "unique_doc_id",
  "doc_type": "event|skill|interest|quirk|personality",

  // 文档内容
  "title": "string",
  "description": "string",
  "tags": ["tag1", "tag2"],

  // 类型特定字段
  "emotional_impact": 0,  // for events
  "level": 0,             // for skills
  "intensity": 0,         // for interests
  "is_uncommon": false,   // for quirks

  // 隐私
  "privacy_level": "private|semi|public",

  // 时间戳
  "timestamp": 1234567890
}
```

**向量化策略:**

1. **Events**: 向量化 title + description + tags
2. **Skills**: 向量化 name + category
3. **Interests**: 向量化 name + category
4. **Quirks**: 向量化 description + tags
5. **Personality**: 向量化所有trait的组合

---

## Redis Schema

### 1. 会话缓存
```
Key: session:{token_hash}
Value: JSON(user_id, expires_at, ...)
TTL: 7天
```

### 2. 用户画像缓存
```
Key: profile:{user_id}
Value: JSON(UserProfile)
TTL: 1小时
```

### 3. Feed缓存
```
Key: feed:{user_id}:page:{page_number}
Value: JSON([FeedItem])
TTL: 5分钟
```

### 4. Agent对话缓存
```
Key: agent:conversation:{user_id}
Value: JSON([AgentMessage])
TTL: 24小时
```

### 5. 速率限制
```
Key: ratelimit:{user_id}:{endpoint}
Value: request_count
TTL: 1分钟/1小时（根据限制类型）
```

---

## 数据迁移策略

### Phase 1: 初始化（开发环境）
1. 创建PostgreSQL数据库和表
2. 创建MongoDB collections和索引
3. 初始化Pinecone index
4. 配置Redis

### Phase 2: 种子数据
1. 创建测试用户
2. 生成示例性格测试
3. 创建示例事件和洞察

### Phase 3: 生产环境
1. 数据库备份策略
2. 向量数据库定期重建
3. 缓存预热

---

## 数据隐私与安全

### 加密策略

1. **传输加密**: 全部HTTPS/TLS
2. **存储加密**:
   - PostgreSQL: 密码使用bcrypt
   - MongoDB: 敏感字段（quirks）使用应用层加密
   - 向量数据库: metadata中不存储敏感原文

### 访问控制

1. **私密数据** (privacy_level="private"):
   - 只在应用层解密
   - 向量化后存储，不保留明文

2. **半公开数据** (privacy_level="semi"):
   - 用于匿名匹配
   - 不在Feed流展示

3. **公开数据** (privacy_level="public"):
   - "裸奔"模式
   - 可在Feed流展示

### GDPR合规

1. **数据导出**: 用户可导出所有数据
2. **数据删除**:
   - PostgreSQL: 软删除（is_active=false）
   - MongoDB: 标记删除
   - 向量数据库: 完全删除向量
   - 区块链: 无法删除NFT，但可销毁
3. **数据可携带性**: JSON格式导出

---

## 性能优化

### 查询优化
1. 索引优化（已在上述schema中定义）
2. 读写分离（主从复制）
3. 分片策略（按user_id分片）

### 缓存策略
1. Redis多层缓存
2. CDN缓存静态资源
3. 向量数据库结果缓存

### 监控指标
1. 查询响应时间
2. 缓存命中率
3. 向量检索性能
4. 数据库连接池使用率

---

**文档版本**: v1.0
**最后更新**: 2025-11-12

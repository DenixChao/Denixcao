# Ego App - 开发指南

本文档为开发者提供详细的开发指南，包括环境搭建、编码规范、最佳实践等。

---

## 📋 目录

1. [开发环境](#开发环境)
2. [项目结构](#项目结构)
3. [编码规范](#编码规范)
4. [Git工作流](#git工作流)
5. [测试策略](#测试策略)
6. [部署流程](#部署流程)
7. [故障排查](#故障排查)

---

## 🛠️ 开发环境

### 1. iOS开发环境

#### 必需软件
- macOS 13+ (Ventura或更高)
- Xcode 15+
- CocoaPods 1.12+ 或 Swift Package Manager
- iOS Simulator 17+

#### 可选工具
- **Sourcery**: 代码生成
- **SwiftLint**: 代码规范检查
- **Fastlane**: 自动化部署
- **Charles/Proxyman**: 网络调试

#### 安装SwiftLint
```bash
brew install swiftlint

# 在Xcode中添加Build Phase
# Run Script:
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

### 2. 后端开发环境

#### 必需软件
- Python 3.11+
- PostgreSQL 15+
- MongoDB 6+
- Redis 7+
- Docker & Docker Compose (推荐)

#### Python虚拟环境
```bash
# 创建虚拟环境
python -m venv venv

# 激活
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# 安装依赖
pip install -r requirements.txt
pip install -r requirements-dev.txt  # 开发依赖
```

#### 使用Docker快速启动
```bash
cd EgoApp/Backend
docker-compose up -d

# 服务:
# - PostgreSQL: localhost:5432
# - MongoDB: localhost:27017
# - Redis: localhost:6379
# - Pinecone: 需要云服务API key
```

### 3. 区块链开发环境

#### 必需软件
- Node.js 18+
- Hardhat
- MetaMask浏览器插件

#### 安装Hardhat
```bash
cd EgoApp/Contracts
npm install --save-dev hardhat
npx hardhat init
```

#### 配置本地测试网络
```bash
# 启动本地节点
npx hardhat node

# 在另一个终端部署合约
npx hardhat run scripts/deploy.js --network localhost
```

---

## 📁 项目结构

### iOS项目结构
```
EgoApp/iOS/Ego/
├── App/
│   └── EgoApp.swift           # App入口
├── Models/
│   ├── User.swift             # 用户模型
│   ├── Agent.swift            # Agent模型
│   └── PersonalityTest.swift # 测试模型
├── Views/
│   ├── ContentView.swift      # 主视图
│   ├── FeedView.swift         # Feed流
│   ├── AgentView.swift        # Agent界面
│   ├── ProfileView.swift      # 个人页
│   └── WalletView.swift       # 钱包
├── ViewModels/
│   ├── FeedViewModel.swift
│   ├── AgentViewModel.swift
│   └── ProfileViewModel.swift
├── Services/
│   ├── APIClient.swift        # 网络层
│   ├── AuthenticationService.swift
│   ├── ProfileService.swift
│   ├── FeedService.swift
│   └── AgentService.swift
├── Utils/
│   ├── Extensions/
│   ├── Constants.swift
│   └── Helpers.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### 后端项目结构
```
EgoApp/Backend/
├── app/
│   ├── api/v1/                # API路由
│   │   ├── auth.py
│   │   ├── profile.py
│   │   ├── feed.py
│   │   ├── agent.py
│   │   └── web3.py
│   ├── core/                  # 核心配置
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── vector_db.py
│   │   └── security.py
│   ├── models/                # 数据模型
│   │   ├── user.py
│   │   ├── profile.py
│   │   └── schemas.py
│   ├── services/              # 业务逻辑
│   │   ├── rag_agent.py       # RAG核心
│   │   ├── recommendation.py  # 推荐算法
│   │   ├── embedding.py       # 向量化
│   │   └── web3_service.py    # Web3集成
│   └── utils/
├── tests/                     # 测试
├── alembic/                   # 数据库迁移
├── scripts/                   # 工具脚本
├── main.py                    # 入口文件
└── requirements.txt
```

---

## 📝 编码规范

### Swift编码规范

#### 命名规范
```swift
// ✅ 好的命名
class UserProfileViewModel { }
func loadUserData() { }
var isLoading: Bool = false
let kMaxRetryCount = 3

// ❌ 不好的命名
class UPVM { }
func load() { }
var loading: Bool = false
let MAX = 3
```

#### 代码组织
```swift
// MARK: - 使用MARK组织代码
class FeedViewModel {
    // MARK: - Properties
    @Published var feedItems: [FeedItem] = []

    // MARK: - Lifecycle
    init() { }

    // MARK: - Public Methods
    func loadFeed() async { }

    // MARK: - Private Methods
    private func processItems() { }
}
```

#### SwiftUI最佳实践
```swift
// ✅ 提取子视图
struct FeedView: View {
    var body: some View {
        ScrollView {
            FeedHeader()  // 提取复杂视图
            FeedContent()
        }
    }
}

// ✅ 使用@ViewBuilder
@ViewBuilder
func makeCard(item: FeedItem) -> some View {
    if item.isQuirky {
        QuirkyCard(item: item)
    } else {
        NormalCard(item: item)
    }
}

// ✅ 避免在body中做复杂计算
// 使用computed property
var filteredItems: [FeedItem] {
    feedItems.filter { $0.isPublic }
}
```

### Python编码规范

#### PEP 8标准
```python
# ✅ 好的命名
class UserProfileService:
    def get_user_profile(self, user_id: str) -> UserProfile:
        pass

# ❌ 不好的命名
class UPS:
    def get(self, id):
        pass
```

#### Type Hints
```python
# ✅ 使用类型注解
from typing import List, Optional, Dict, Any

async def get_feed_items(
    user_id: str,
    page: int = 0,
    page_size: int = 20
) -> List[FeedItem]:
    pass

# ✅ 使用Pydantic进行验证
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: str = Field(..., regex=r"^\S+@\S+\.\S+$")
    password: str = Field(..., min_length=8)
```

#### 异步编程
```python
# ✅ 使用async/await
async def query_agent(question: str) -> AgentResponse:
    # 并发执行多个异步操作
    embedding_task = asyncio.create_task(get_embedding(question))
    context_task = asyncio.create_task(retrieve_context(question))

    embedding, context = await asyncio.gather(
        embedding_task,
        context_task
    )

    return await generate_response(embedding, context)
```

#### 错误处理
```python
# ✅ 具体的异常处理
from fastapi import HTTPException

async def get_user_profile(user_id: str):
    try:
        profile = await db.profiles.find_one({"user_id": user_id})
        if not profile:
            raise HTTPException(status_code=404, detail="Profile not found")
        return profile
    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        raise HTTPException(status_code=500, detail="Database error")
```

### Solidity编码规范

```solidity
// ✅ 使用NatSpec注释
/**
 * @dev 铸造数据资产NFT
 * @param ipfsHash IPFS上的加密数据哈希
 * @return tokenId 新铸造的token ID
 */
function mintDataAsset(string memory ipfsHash) public returns (uint256) {
    // 实现
}

// ✅ 使用require进行输入验证
require(msg.sender != address(0), "Invalid sender");
require(bytes(ipfsHash).length > 0, "IPFS hash cannot be empty");

// ✅ 使用event记录重要操作
event DataAssetMinted(address indexed owner, uint256 indexed tokenId, string ipfsHash);
emit DataAssetMinted(msg.sender, newTokenId, ipfsHash);
```

---

## 🌿 Git工作流

### 分支策略

```
main (生产环境)
  ├── develop (开发主分支)
  │     ├── feature/feed-algorithm (功能分支)
  │     ├── feature/rag-agent (功能分支)
  │     └── feature/web3-integration (功能分支)
  └── hotfix/critical-bug (紧急修复)
```

### 分支命名规范
- **功能**: `feature/feed-recommendation`
- **修复**: `fix/login-error`
- **重构**: `refactor/api-client`
- **文档**: `docs/api-documentation`
- **测试**: `test/agent-service`

### Commit消息规范

使用[Conventional Commits](https://www.conventionalcommits.org/)：

```bash
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

**类型**:
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档
- `style`: 格式（不影响代码运行）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试
- `chore`: 构建/工具

**示例**:
```bash
feat(feed): add quirky match algorithm

Implement algorithm to discover uncommon similarities between users.
Uses low-frequency tags and high semantic similarity.

Closes #123
```

### Pull Request流程

1. **创建分支**
```bash
git checkout -b feature/amazing-feature
```

2. **开发并提交**
```bash
git add .
git commit -m "feat: add amazing feature"
```

3. **推送到远程**
```bash
git push origin feature/amazing-feature
```

4. **创建PR**
   - 填写PR模板
   - 关联相关Issue
   - 请求Code Review

5. **Code Review**
   - 至少1个approve
   - CI/CD通过
   - 解决所有comments

6. **合并**
   - Squash and merge (保持历史整洁)
   - 删除feature分支

---

## 🧪 测试策略

### iOS测试

#### 单元测试
```swift
import XCTest
@testable import Ego

class FeedViewModelTests: XCTestCase {
    var viewModel: FeedViewModel!
    var mockFeedService: MockFeedService!

    override func setUp() {
        super.setUp()
        mockFeedService = MockFeedService()
        viewModel = FeedViewModel(feedService: mockFeedService)
    }

    func testLoadInitialFeed() async throws {
        // Given
        let expectedItems = [/* mock data */]
        mockFeedService.mockFeedItems = expectedItems

        // When
        await viewModel.loadInitialFeed()

        // Then
        XCTAssertEqual(viewModel.feedItems.count, expectedItems.count)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

#### UI测试
```swift
class EgoUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testFeedScrolling() {
        // Given
        let feedScrollView = app.scrollViews["feedScrollView"]

        // When
        feedScrollView.swipeUp()

        // Then
        XCTAssertTrue(feedScrollView.exists)
    }
}
```

### 后端测试

#### 单元测试
```python
import pytest
from app.services.rag_agent import RAGAgent

@pytest.mark.asyncio
async def test_agent_query():
    # Given
    agent = RAGAgent()
    question = "What are my core values?"

    # When
    response = await agent.query(
        user_id="test-user",
        question=question
    )

    # Then
    assert response.answer is not None
    assert response.confidence > 0
    assert len(response.sources) > 0
```

#### 集成测试
```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_feed_endpoint():
    # When
    response = client.get(
        "/api/v1/feed",
        headers={"Authorization": f"Bearer {test_token}"}
    )

    # Then
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
```

### 智能合约测试

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EgoDataAsset", function () {
  let egoDataAsset;
  let owner, user1;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();

    const EgoDataAsset = await ethers.getContractFactory("EgoDataAsset");
    egoDataAsset = await EgoDataAsset.deploy(egoTokenAddress);
  });

  it("Should mint data asset NFT", async function () {
    const ipfsHash = "QmTest123";

    await egoDataAsset.connect(user1).mintDataAsset(ipfsHash);

    const dataAsset = await egoDataAsset.getUserDataAsset(user1.address);
    expect(dataAsset.ipfsHash).to.equal(ipfsHash);
  });
});
```

---

## 🚀 部署流程

### 后端部署 (AWS/DigitalOcean)

#### 1. 使用Docker部署
```bash
# 构建镜像
docker build -t ego-backend:latest .

# 推送到Registry
docker tag ego-backend:latest registry.example.com/ego-backend:latest
docker push registry.example.com/ego-backend:latest

# 在服务器上运行
docker pull registry.example.com/ego-backend:latest
docker run -d \
  --name ego-backend \
  -p 8000:8000 \
  --env-file .env \
  registry.example.com/ego-backend:latest
```

#### 2. 使用Docker Compose
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  api:
    image: registry.example.com/ego-backend:latest
    ports:
      - "8000:8000"
    env_file:
      - .env.production
    depends_on:
      - postgres
      - mongodb
      - redis

  postgres:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:6
    volumes:
      - mongo_data:/data/db

  redis:
    image: redis:7
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  mongo_data:
  redis_data:
```

### iOS部署 (App Store)

#### 使用Fastlane自动化
```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "Ego")
    upload_to_testflight
  end

  desc "Push a new release build to the App Store"
  lane :release do
    increment_build_number
    build_app(scheme: "Ego")
    upload_to_app_store
  end
end
```

```bash
# 部署到TestFlight
fastlane beta

# 部署到App Store
fastlane release
```

### 智能合约部署

```bash
# 部署到Polygon Mumbai测试网
npx hardhat run scripts/deploy.js --network polygonMumbai

# 部署到Polygon主网
npx hardhat run scripts/deploy.js --network polygon

# 验证合约
npx hardhat verify --network polygon CONTRACT_ADDRESS CONSTRUCTOR_ARGS
```

---

## 🔍 故障排查

### 常见问题

#### 1. iOS构建失败
```bash
# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean

# 重新安装Pod
pod deintegrate
pod install
```

#### 2. 后端数据库连接失败
```bash
# 检查PostgreSQL状态
pg_isready -h localhost -p 5432

# 检查MongoDB状态
mongosh --eval "db.adminCommand('ping')"

# 检查连接字符串
echo $DATABASE_URL
```

#### 3. 向量数据库查询慢
```python
# 优化: 减少top_k
results = vector_store.query(embedding, top_k=5)  # 从10降到5

# 优化: 使用filter减少搜索空间
results = vector_store.query(
    embedding,
    top_k=5,
    filter={"privacy_level": "public"}
)
```

#### 4. 智能合约Gas费过高
```javascript
// 使用estimateGas预估
const gasEstimate = await contract.estimateGas.mintDataAsset(ipfsHash);
console.log("Estimated gas:", gasEstimate.toString());

// 批量操作减少Gas
await contract.batchMint([ipfsHash1, ipfsHash2, ipfsHash3]);
```

---

## 📚 参考资源

### 官方文档
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [FastAPI](https://fastapi.tiangolo.com/)
- [LangChain](https://python.langchain.com/)
- [Hardhat](https://hardhat.org/docs)

### 学习资源
- [iOS开发最佳实践](https://github.com/futurice/ios-good-practices)
- [Python异步编程](https://realpython.com/async-io-python/)
- [智能合约安全](https://consensys.github.io/smart-contract-best-practices/)

---

**祝开发顺利！如有问题，请在GitHub Issues提问或加入Discord社区讨论。**

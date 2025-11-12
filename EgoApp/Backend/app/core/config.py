"""
配置管理
"""

from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # 应用配置
    APP_NAME: str = "Ego"
    DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"

    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "https://ego.app",
    ]

    # 数据库配置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+asyncpg://ego:password@localhost/ego_db"
    )

    # MongoDB配置
    MONGODB_URL: str = os.getenv(
        "MONGODB_URL",
        "mongodb://localhost:27017"
    )
    MONGODB_DB_NAME: str = "ego"

    # Redis配置
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")

    # 向量数据库配置 (Pinecone)
    PINECONE_API_KEY: str = os.getenv("PINECONE_API_KEY", "")
    PINECONE_ENVIRONMENT: str = os.getenv("PINECONE_ENVIRONMENT", "us-west1-gcp")
    PINECONE_INDEX_NAME: str = "ego-users"

    # AI配置
    ANTHROPIC_API_KEY: str = os.getenv("ANTHROPIC_API_KEY", "")
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")

    # Embedding模型
    EMBEDDING_MODEL: str = "sentence-transformers/all-MiniLM-L6-v2"
    EMBEDDING_DIMENSION: int = 384

    # Web3配置
    WEB3_PROVIDER_URL: str = os.getenv(
        "WEB3_PROVIDER_URL",
        "https://polygon-mumbai.infura.io/v3/YOUR_KEY"
    )
    DATA_ASSET_CONTRACT_ADDRESS: str = os.getenv("DATA_ASSET_CONTRACT_ADDRESS", "")

    # IPFS配置
    IPFS_API_URL: str = os.getenv("IPFS_API_URL", "/ip4/127.0.0.1/tcp/5001")

    # JWT配置
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天

    # 推荐算法配置
    FEED_PAGE_SIZE: int = 20
    QUIRKY_MATCH_THRESHOLD: float = 0.3  # 异类共鸣阈值（低频标签）
    MIN_MATCH_SCORE: float = 0.6  # 最小匹配分数

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()

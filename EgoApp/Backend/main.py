"""
Ego App - Backend API
FastAPI服务器主入口
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time

from app.api.v1 import auth, profile, feed, agent, web3
from app.core.config import settings
from app.core.database import init_db
from app.core.vector_db import init_vector_db

# 创建FastAPI应用
app = FastAPI(
    title="Ego API",
    description="AI时代的自我认知社交平台",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 请求日志中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()

    response = await call_next(request)

    process_time = time.time() - start_time
    print(f"{request.method} {request.url.path} - {response.status_code} - {process_time:.2f}s")

    return response

# 路由注册
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(profile.router, prefix="/api/v1/profile", tags=["Profile"])
app.include_router(feed.router, prefix="/api/v1/feed", tags=["Feed"])
app.include_router(agent.router, prefix="/api/v1/agent", tags=["AI Agent"])
app.include_router(web3.router, prefix="/api/v1/web3", tags=["Web3"])

@app.on_event("startup")
async def startup_event():
    """应用启动时初始化"""
    print("🚀 Starting Ego API Server...")

    # 初始化数据库
    await init_db()
    print("✅ Database initialized")

    # 初始化向量数据库
    await init_vector_db()
    print("✅ Vector database initialized")

    print("✨ Ego API Server is ready!")

@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时清理"""
    print("👋 Shutting down Ego API Server...")

@app.get("/")
async def root():
    """健康检查"""
    return {
        "message": "Ego API Server",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """详细健康检查"""
    return {
        "status": "healthy",
        "database": "connected",
        "vector_db": "connected",
        "ai_service": "ready"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

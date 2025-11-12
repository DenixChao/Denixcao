"""
RAG Agent服务
用户的AI数字分身
"""

from typing import List, Dict, Any
from anthropic import Anthropic
import numpy as np
from sentence_transformers import SentenceTransformer

from app.core.config import settings
from app.core.vector_db import vector_store
from app.models.schemas import (
    UserProfile,
    AgentQuery,
    AgentResponse,
    Insight,
    RelationshipPrediction
)

class RAGAgent:
    """
    RAG Agent - 基于检索增强生成的AI分身
    """

    def __init__(self):
        self.anthropic = Anthropic(api_key=settings.ANTHROPIC_API_KEY)
        self.embedding_model = SentenceTransformer(settings.EMBEDDING_MODEL)

    async def query(self, user_id: str, question: str, context: Dict[str, Any] = None) -> AgentResponse:
        """
        查询Agent

        流程:
        1. 将问题向量化
        2. 在向量数据库中检索相关的用户数据
        3. 构建上下文
        4. 调用Claude生成回答
        """

        # 1. 向量化问题
        question_embedding = self.embedding_model.encode(question).tolist()

        # 2. 检索相关上下文（从用户的知识库）
        retrieved_docs = await vector_store.similarity_search(
            user_id=user_id,
            query_embedding=question_embedding,
            top_k=5
        )

        # 3. 构建上下文字符串
        context_text = self._build_context(retrieved_docs)

        # 4. 构建系统提示词
        system_prompt = f"""你是用户的AI数字分身，深度了解他们的经历、性格、喜好和癖好。

基于以下用户数据回答问题:

{context_text}

回答要求:
- 以第一人称的方式回答，就像用户在自我反思
- 引用具体的事件和数据
- 提供洞察和建议
- 帮助用户认识自己
- 发现用户可能忽视的模式
"""

        # 5. 调用Claude API
        response = self.anthropic.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=1024,
            system=system_prompt,
            messages=[
                {"role": "user", "content": question}
            ]
        )

        answer = response.content[0].text

        # 6. 构建响应
        return AgentResponse(
            answer=answer,
            confidence=0.85,  # TODO: 计算实际置信度
            sources=[
                {
                    "id": doc["id"],
                    "type": doc["type"],
                    "reference": doc["title"],
                    "relevance": doc["score"]
                }
                for doc in retrieved_docs
            ],
            suggestedFollowUps=self._generate_followup_questions(question, answer)
        )

    def _build_context(self, docs: List[Dict]) -> str:
        """构建检索到的文档的上下文文本"""
        context_parts = []

        for doc in docs:
            doc_type = doc.get("type", "unknown")

            if doc_type == "event":
                context_parts.append(
                    f"关键事件: {doc['title']}\n"
                    f"描述: {doc['description']}\n"
                    f"情感影响: {doc.get('emotional_impact', 0)}\n"
                )
            elif doc_type == "skill":
                context_parts.append(
                    f"技能: {doc['name']} (等级: {doc.get('level', 0)}/10)\n"
                )
            elif doc_type == "interest":
                context_parts.append(
                    f"兴趣: {doc['name']} (强度: {doc.get('intensity', 0)}/10)\n"
                )
            elif doc_type == "quirk":
                context_parts.append(
                    f"癖好: {doc['description']}\n"
                )

        return "\n".join(context_parts)

    def _generate_followup_questions(self, question: str, answer: str) -> List[str]:
        """生成后续建议问题"""
        # 简单实现，实际可以用AI生成
        followups = [
            "这对我的未来发展有什么启示？",
            "有多少人和我有类似的经历？",
            "基于这些，我应该如何做决策？"
        ]
        return followups

    async def generate_insights(self, user_id: str, profile: UserProfile) -> List[Insight]:
        """
        生成个性化洞察

        分析用户数据，发现模式，生成洞察
        """
        insights = []

        # 1. 性格洞察
        personality_insight = await self._generate_personality_insight(profile)
        if personality_insight:
            insights.append(personality_insight)

        # 2. 行为模式洞察
        pattern_insight = await self._generate_pattern_insight(profile)
        if pattern_insight:
            insights.append(pattern_insight)

        # 3. "你并不孤单"洞察
        commonality_insight = await self._generate_commonality_insight(user_id, profile)
        if commonality_insight:
            insights.append(commonality_insight)

        return insights

    async def _generate_personality_insight(self, profile: UserProfile) -> Insight:
        """生成性格洞察"""
        if not profile.personality_traits:
            return None

        # 分析性格特质，生成洞察
        traits_text = "\n".join([
            f"{trait['name']}: {trait['score']}"
            for trait in profile.personality_traits
        ])

        prompt = f"""基于以下性格特质，生成一个简短的洞察（不超过100字）:

{traits_text}

洞察应该:
1. 指出最突出的特质
2. 这些特质如何影响用户的行为
3. 给出一个建议"""

        response = self.anthropic.messages.create(
            model="claude-3-5-haiku-20241022",  # 使用更快的模型
            max_tokens=200,
            messages=[{"role": "user", "content": prompt}]
        )

        return Insight(
            type="personality",
            title="你的性格画像",
            content=response.content[0].text,
            confidence=0.8,
            supporting_data=[]
        )

    async def _generate_pattern_insight(self, profile: UserProfile) -> Insight:
        """生成行为模式洞察"""
        # 分析关键事件，发现模式
        if not profile.key_events or len(profile.key_events) < 3:
            return None

        # 简单示例：分析情感影响模式
        events_by_impact = sorted(
            profile.key_events,
            key=lambda e: e.get("emotional_impact", 0),
            reverse=True
        )

        high_impact_events = events_by_impact[:3]

        return Insight(
            type="pattern",
            title="你的情感模式",
            content=f"你对 {high_impact_events[0]['title']} 类型的事件反应最强烈，这可能是你的核心价值所在。",
            confidence=0.7,
            supporting_data=[e["id"] for e in high_impact_events]
        )

    async def _generate_commonality_insight(self, user_id: str, profile: UserProfile) -> Insight:
        """生成"你并不孤单"类型的洞察"""
        # 查找相似用户
        similar_users_count = await self._count_similar_users(user_id, profile)

        if similar_users_count > 0:
            return Insight(
                type="commonality",
                title="你并不孤单",
                content=f"有 {similar_users_count} 个人和你有着相似的特质和经历。你以为自己是异类的地方，其实也有很多人与你共鸣。",
                confidence=0.9,
                supporting_data=[]
            )

        return None

    async def _count_similar_users(self, user_id: str, profile: UserProfile) -> int:
        """统计相似用户数量"""
        # TODO: 实现实际的相似用户统计
        # 这里应该在向量数据库中查找相似用户
        return 247  # 示例数据

    async def predict_relationships(self, user_id: str, profile: UserProfile) -> List[RelationshipPrediction]:
        """
        预测用户可能产生关系的人群

        基于用户画像，生成理想连接的人群画像
        """
        predictions = []

        # 1. 基于性格互补性预测
        complementary_prediction = await self._predict_complementary_relationships(profile)
        if complementary_prediction:
            predictions.append(complementary_prediction)

        # 2. 基于共同兴趣预测
        interest_prediction = await self._predict_interest_relationships(profile)
        if interest_prediction:
            predictions.append(interest_prediction)

        # 3. 基于"异类共鸣"预测
        quirky_prediction = await self._predict_quirky_relationships(user_id, profile)
        if quirky_prediction:
            predictions.append(quirky_prediction)

        return predictions

    async def _predict_complementary_relationships(self, profile: UserProfile) -> RelationshipPrediction:
        """预测互补性关系"""
        # 简化示例
        return RelationshipPrediction(
            archetype="理性浪漫主义者",
            traits=["高开放性", "低神经质", "创造力强"],
            match_score=0.82,
            common_quirks=["喜欢深夜独自思考", "对艺术有独特品味"],
            common_interests=["哲学", "现代艺术"],
            insight="你们都是思考者，但表达方式不同。这种互补能产生有趣的化学反应。",
            matched_users_count=156
        )

    async def _predict_interest_relationships(self, profile: UserProfile) -> RelationshipPrediction:
        """基于兴趣预测关系"""
        return None

    async def _predict_quirky_relationships(self, user_id: str, profile: UserProfile) -> RelationshipPrediction:
        """预测"异类共鸣"关系"""
        # 找到低频但高匹配的特质
        return RelationshipPrediction(
            archetype="午夜散步者",
            traits=["夜行动物", "独处爱好者", "感知敏锐"],
            match_score=0.75,
            common_quirks=["午夜独自散步", "暴雨中的宁静感"],
            common_interests=[],
            insight="你们共同拥有这些看似奇怪的习惯，但这正是你们独特的美。",
            matched_users_count=47
        )

# 全局实例
rag_agent = RAGAgent()

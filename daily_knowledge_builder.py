#!/usr/bin/env python3
"""
用户专属知识库自动构建器
每天自动总结对话，提取偏好、禁忌、常用操作、目标、计划
"""
import pymysql
import json
import os
import sys
from datetime import datetime, timedelta
import re

DB_CONFIG = {
    'host': '192.168.3.241',
    'port': 33061,
    'user': 'openclaw',
    'password': '0penC1aw',
    'database': 'openclaw',
    'charset': 'utf8mb4'
}

class KnowledgeBuilder:
    def __init__(self):
        self.conn = pymysql.connect(**DB_CONFIG)
        self.today = datetime.now().strftime('%Y-%m-%d')
    
    def close(self):
        self.conn.close()
    
    # 获取近期对话
    def get_recent_conversations(self, days=7):
        cursor = self.conn.cursor()
        cursor.execute(f'''
            SELECT user_id, session_id, role, content, created_at 
            FROM conversation_history 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL {days} DAY)
            ORDER BY created_at DESC
        ''')
        return cursor.fetchall()
    
    # 按用户分组对话
    def group_by_user(self, conversations):
        user_convos = {}
        for conv in conversations:
            user_id = conv[0]
            if user_id not in user_convos:
                user_convos[user_id] = []
            user_convos[user_id].append({
                'role': conv[2],
                'content': conv[3],
                'time': conv[4]
            })
        return user_convos
    
    # 提取偏好
    def extract_preferences(self, messages):
        preferences = []
        keywords = ['喜欢', '爱', '想要', '希望', '偏好', '欣赏', '支持']
        
        for msg in messages:
            if msg['role'] != 'user':
                continue
            content = msg['content']
            for kw in keywords:
                if kw in content:
                    # 提取关键词周围的句子
                    idx = content.find(kw)
                    start = max(0, idx - 20)
                    end = min(len(content), idx + 30)
                    preferences.append(content[start:end])
        
        return list(set(preferences))[:10]
    
    # 提取禁忌/厌恶
    def extract_taboos(self, messages):
        taboos = []
        keywords = ['讨厌', '不喜欢', '不要', '别', '禁忌', '反感', '厌恶']
        
        for msg in messages:
            if msg['role'] != 'user':
                continue
            content = msg['content']
            for kw in keywords:
                if kw in content:
                    idx = content.find(kw)
                    start = max(0, idx - 20)
                    end = min(len(content), idx + 30)
                    taboos.append(content[start:end])
        
        return list(set(taboos))[:10]
    
    # 提取常用操作
    def extract_operations(self, messages):
        operations = []
        keywords = ['测试', '运行', '执行', '开发', '修改', '更新', '创建', '安装', '配置']
        
        for msg in messages:
            if msg['role'] != 'user':
                continue
            content = msg['content']
            for kw in keywords:
                if kw in content:
                    # 提取命令或操作
                    operations.append(kw)
        
        from collections import Counter
        counter = Counter(operations)
        return [op for op, _ in counter.most_common(10)]
    
    # 提取目标/计划
    def extract_goals(self, messages):
        goals = []
        keywords = ['目标', '计划', '想要做', '要做', '需要', '应该', '开发', '实现']
        
        for msg in messages:
            if msg['role'] != 'user':
                continue
            content = msg['content']
            for kw in keywords:
                if kw in content:
                    idx = content.find(kw)
                    start = max(0, idx - 20)
                    end = min(len(content), idx + 40)
                    goals.append(content[start:end])
        
        return list(set(goals))[:10]
    
    # 构建知识库
    def build_knowledge(self, user_id, messages):
        knowledge = {
            'preferences': self.extract_preferences(messages),
            'taboos': self.extract_taboos(messages),
            'operations': self.extract_operations(messages),
            'goals': self.extract_goals(messages),
            'last_updated': self.today
        }
        return knowledge
    
    # 保存到数据库
    def save_knowledge(self, user_id, knowledge):
        cursor = self.conn.cursor()
        
        # 更新 user_profile 表
        cursor.execute('''
            UPDATE user_profile 
            SET preferences = %s, last_updated = NOW()
            WHERE user_id = %s
        ''', (json.dumps(knowledge, ensure_ascii=False), user_id))
        
        # 如果没有记录，插入新记录
        if cursor.rowcount == 0:
            cursor.execute('''
                INSERT INTO user_profile (user_id, preferences, created_at)
                VALUES (%s, %s, NOW())
            ''', (user_id, json.dumps(knowledge, ensure_ascii=False)))
        
        self.conn.commit()
    
    # 每日构建
    def daily_build(self):
        print(f"📚 开始构建知识库... {self.today}")
        
        # 获取近期对话
        conversations = self.get_recent_conversations(days=7)
        print(f"📬 获取到 {len(conversations)} 条对话记录")
        
        if not conversations:
            print("没有对话记录")
            return
        
        # 按用户分组
        user_convos = self.group_by_user(conversations)
        print(f"👥 涉及 {len(user_convos)} 个用户")
        
        # 为每个用户构建知识库
        for user_id, messages in user_convos.items():
            knowledge = self.build_knowledge(user_id, messages)
            self.save_knowledge(user_id, knowledge)
            
            print(f"\n✅ 用户 {user_id[:20]}...")
            print(f"   偏好: {len(knowledge['preferences'])}条")
            print(f"   禁忌: {len(knowledge['taboos'])}条")
            print(f"   操作: {len(knowledge['operations'])}条")
            print(f"   目标: {len(knowledge['goals'])}条")
        
        print("\n✨ 知识库构建完成！")

# CLI
if __name__ == '__main__':
    builder = KnowledgeBuilder()
    
    if len(sys.argv) > 1 and sys.argv[1] == 'run':
        builder.daily_build()
    else:
        # 测试运行
        print("用户知识库构建器")
        print(f"今日: {builder.today}")
        
        # 显示最近的用户
        conversations = builder.get_recent_conversations(days=1)
        user_convos = builder.group_by_user(conversations)
        
        for user_id, msgs in user_convos.items():
            print(f"\n用户: {user_id}")
            print(f"消息数: {len(msgs)}")
            
            # 提取并显示
            prefs = builder.extract_preferences(msgs)
            if prefs:
                print(f"偏好: {prefs[:3]}")
            
            ops = builder.extract_operations(msgs)
            if ops:
                print(f"常用操作: {ops[:5]}")
    
    builder.close()

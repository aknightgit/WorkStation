#!/usr/bin/env python3
"""
长期记忆服务 - MariaDB持久化
自动记录对话历史、用户偏好、学习习惯
"""
import pymysql
import json
import os
from datetime import datetime

DB_CONFIG = {
    'host': '192.168.3.241',
    'port': 33061,
    'user': 'openclaw',
    'password': '0penC1aw',
    'database': 'changqingge',
    'charset': 'utf8mb4'
}

class LongTermMemory:
    def __init__(self):
        self.conn = pymysql.connect(**DB_CONFIG)
    
    def close(self):
        self.conn.close()
    
    # ========== 记忆存储 ==========
    def store_memory(self, category, key_name, value, importance=3, source='auto'):
        """存储记忆"""
        cursor = self.conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO long_term_memory (category, key_name, value, importance, source)
                VALUES (%s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE value=%s, importance=%s, updated_at=CURRENT_TIMESTAMP
            ''', (category, key_name, value, importance, source, value, importance))
            self.conn.commit()
            return True
        except Exception as e:
            print(f"存储记忆失败: {e}")
            return False
    
    def store_preference(self, key_name, value, importance=4):
        """存储用户偏好"""
        return self.store_memory('preference', key_name, json.dumps(value) if isinstance(value, dict) else value, importance, 'chat')
    
    def store_habit(self, key_name, value):
        """存储习惯"""
        return self.store_memory('habit', key_name, json.dumps(value) if isinstance(value, dict) else value, 3, 'auto')
    
    def store_requirement(self, key_name, value, importance=5):
        """存储需求"""
        return self.store_memory('requirement', key_name, json.dumps(value) if isinstance(value, dict) else value, importance, 'chat')
    
    def store_personality(self, key_name, value):
        """存储性格特征"""
        return self.store_memory('personality', key_name, json.dumps(value) if isinstance(value, dict) else value, 4, 'chat')
    
    def store_command(self, key_name, value):
        """存储常用指令"""
        return self.store_memory('command', key_name, value, 2, 'chat')
    
    # ========== 记忆查询 ==========
    def get_memory(self, category, key_name):
        """获取单条记忆"""
        cursor = self.conn.cursor()
        cursor.execute('SELECT value FROM long_term_memory WHERE category=%s AND key_name=%s', (category, key_name))
        result = cursor.fetchone()
        return result[0] if result else None
    
    def get_all_preferences(self):
        """获取所有偏好"""
        return self.get_memories_by_category('preference')
    
    def get_all_habits(self):
        """获取所有习惯"""
        return self.get_memories_by_category('habit')
    
    def get_memories_by_category(self, category, min_importance=1):
        """按分类获取记忆"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT key_name, value, importance, updated_at 
            FROM long_term_memory 
            WHERE category=%s AND importance >= %s
            ORDER BY importance DESC, updated_at DESC
        ''', (category, min_importance))
        return cursor.fetchall()
    
    def search_memories(self, keyword):
        """搜索记忆"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT category, key_name, value, importance 
            FROM long_term_memory 
            WHERE key_name LIKE %s OR value LIKE %s
            ORDER BY importance DESC
        ''', (f'%{keyword}%', f'%{keyword}%'))
        return cursor.fetchall()
    
    # ========== 对话历史 ==========
    def save_message(self, session_id, user_id, role, content, metadata=None):
        """保存对话消息"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO conversation_history (session_id, user_id, role, content, metadata)
            VALUES (%s, %s, %s, %s, %s)
        ''', (session_id, user_id, role, content, json.dumps(metadata) if metadata else None))
        self.conn.commit()
    
    def get_conversation_history(self, session_id, limit=50):
        """获取对话历史"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT role, content, created_at 
            FROM conversation_history 
            WHERE session_id=%s 
            ORDER BY created_at DESC 
            LIMIT %s
        ''', (session_id, limit))
        return cursor.fetchall()
    
    def get_recent_conversations(self, user_id, days=7, limit=100):
        """获取近期对话"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT session_id, content, created_at 
            FROM conversation_history 
            WHERE user_id=%s AND created_at >= DATE_SUB(NOW(), INTERVAL %s DAY)
            ORDER BY created_at DESC 
            LIMIT %s
        ''', (user_id, days, limit))
        return cursor.fetchall()
    
    # ========== 用户画像 ==========
    def get_user_profile(self, user_id):
        """获取用户画像"""
        cursor = self.conn.cursor()
        cursor.execute('SELECT * FROM user_profile WHERE user_id=%s', (user_id,))
        result = cursor.fetchone()
        if result:
            return {
                'id': result[0],
                'user_id': result[1],
                'name': result[2],
                'preferences': json.loads(result[3]) if result[3] else {},
                'habits': json.loads(result[4]) if result[4] else {},
                'personality': json.loads(result[5]) if result[5] else {},
                'requirements': json.loads(result[6]) if result[6] else {},
                'last_updated': result[7],
                'created_at': result[8]
            }
        return None
    
    def update_user_profile(self, user_id, **kwargs):
        """更新用户画像"""
        cursor = self.conn.cursor()
        fields = []
        values = []
        for key, value in kwargs.items():
            fields.append(f"{key}=%s")
            values.append(json.dumps(value) if isinstance(value, (dict, list)) else value)
        values.append(user_id)
        
        cursor.execute(f'''
            UPDATE user_profile SET {','.join(fields)}, last_updated=CURRENT_TIMESTAMP
            WHERE user_id=%s
        ''', values)
        self.conn.commit()
        return cursor.rowcount > 0
    
    # ========== 自动学习 ==========
    def learn_from_conversation(self, user_id, messages):
        """从对话中自动学习"""
        for msg in messages:
            if msg.get('role') == 'user':
                content = msg.get('content', '')
                # 简单规则：检测偏好/需求关键词
                if '喜欢' in content or '爱' in content:
                    self.store_preference('likes', content, 4)
                if '讨厌' in content or '不喜欢' in content:
                    self.store_preference('dislikes', content, 4)
                if '不要' in content or '别' in content:
                    self.store_habit('avoidance', content)

# ========== CLI 接口 ==========
if __name__ == '__main__':
    import sys
    memory = LongTermMemory()
    
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        
        if cmd == 'store':
            # python memory_service.py store preference likes "足球"
            category, key, value = sys.argv[2], sys.argv[3], sys.argv[4]
            memory.store_memory(category, key, value)
            print(f"✅ 已存储: {category}/{key}")
        
        elif cmd == 'get':
            # python memory_service.py get preference likes
            category, key = sys.argv[2], sys.argv[3]
            result = memory.get_memory(category, key)
            print(result or "无记录")
        
        elif cmd == 'search':
            # python memory_service.py search 麻将
            keyword = sys.argv[2]
            results = memory.search_memories(keyword)
            for r in results:
                print(f"[{r[0]}] {r[1]}: {r[2][:50]}")
        
        elif cmd == 'profile':
            # python memory_service.py profile ou_ac579c5955e2a11fec98b123f73e9e56
            user_id = sys.argv[2]
            profile = memory.get_user_profile(user_id)
            print(json.dumps(profile, ensure_ascii=False, indent=2, default=str))
        
        elif cmd == 'history':
            # python memory_service.py history session123
            session_id = sys.argv[2]
            history = memory.get_conversation_history(session_id)
            for h in history:
                print(f"{h[0]}: {h[1][:50]}")
    else:
        print("长期记忆服务已就绪")
        # 显示最近记忆
        prefs = memory.get_all_preferences()
        print(f"\n已存储偏好: {len(prefs)}条")
        for p in prefs[:5]:
            print(f"  - {p[0]}: {p[1][:30]}")
    
    memory.close()

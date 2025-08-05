import os
import sqlite3
from datetime import datetime
from typing import Optional, Dict, Any, List, Tuple


class TranslationDB:
    def __init__(self, db_path: str) -> None:
        self.db_path = os.path.expanduser(db_path)
        self._ensure_db()

    def _ensure_db(self) -> None:
        if not os.path.exists(self.db_path):
            os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
            print(f'Database not found. Creating at {self.db_path}...')

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS commits (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT,
                    execute_path TEXT,
                    original_message TEXT,
                    translation TEXT
                )
            """)
            conn.commit()

    def insert_commit(
        self, execute_path: str, original_message: str, translation: str
    ) -> None:
        date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO commits (date, execute_path, original_message, translation)
                VALUES (?, ?, ?, ?)
            """,
                (date, execute_path, original_message, translation),
            )
            conn.commit()
        print('Record inserted successfully.')

    def query_commits(
        self, filter_by: Optional[Dict[str, Any]] = None
    ) -> List[Tuple[int, str, str, str, str]]:
        query = (
            'SELECT id, date, execute_path, original_message, translation FROM commits'
        )
        params: List[Any] = []
        if filter_by:
            filters: List[str] = []
            for key, value in filter_by.items():
                if key == 'execute_path':
                    filters.append(f'{key} LIKE ?')
                    params.append(f'{value}%')
                else:
                    filters.append(f'{key} = ?')
                    params.append(value)
            query += ' WHERE ' + ' AND '.join(filters)

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            rows = cursor.fetchall()
        return rows


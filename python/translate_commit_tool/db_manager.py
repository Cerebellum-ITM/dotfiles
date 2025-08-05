import os
import sqlite3
import logging
from datetime import datetime
from logging.handlers import RotatingFileHandler
from typing import Optional, Dict, Any, List, Tuple


LOG_FILE = os.path.expanduser('~/dotfiles/home/.config/.tmp/translation_db.log')
log_dir = os.path.dirname(LOG_FILE)
os.makedirs(log_dir, exist_ok=True)

logger = logging.getLogger('translation_db_logger')
logger.setLevel(logging.DEBUG)

handler = RotatingFileHandler(LOG_FILE, maxBytes=5 * 1024 * 1024, backupCount=3)
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
handler.setFormatter(formatter)

if not logger.hasHandlers():
    logger.addHandler(handler)


class TranslationDB:
    def __init__(self, db_path: str) -> None:
        self.db_path = os.path.expanduser(db_path)
        self._ensure_db()

    def _ensure_db(self) -> None:
        if not os.path.exists(self.db_path):
            os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
            logger.info(f'Database not found. Creating at {self.db_path}...')

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
            inserted_id = cursor.lastrowid
        logger.info(
            f"Record inserted successfully PWD = '{execute_path}', id = {inserted_id}"
        )

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
            query += ' ORDER BY date DESC'

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            rows = cursor.fetchall()
        return rows

    def get_translation_by_id(self, commit_id: int) -> Optional[str]:
        query = 'SELECT translation FROM commits WHERE id = ?'
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(query, (commit_id,))
            result = cursor.fetchone()
        if result:
            return result[0]
        return None


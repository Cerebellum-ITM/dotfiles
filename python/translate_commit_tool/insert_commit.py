import sys
from db_manager import TranslationDB, logger

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(
            'Usage: python insert_commit.py <execute_path> <original_message> <translation>'
        )
        logger.error('The arguments were not received correctly.')
        sys.exit(1)

    execute_path = sys.argv[1]
    original_message = sys.argv[2]
    translation = sys.argv[3]

    db = TranslationDB('~/dotfiles/home/.config/.tmp/fzf-translate_history.db')
    db.insert_commit(execute_path, original_message, translation)

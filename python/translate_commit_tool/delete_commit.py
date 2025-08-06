import sys
from db_manager import TranslationDB, logger

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: python delete_commit.py <commit_id>')
        logger.error('The arguments were not received correctly.')
        sys.exit(1)

    entry_id = int(sys.argv[1])

    db = TranslationDB('~/dotfiles/home/.config/.tmp/fzf-translate_history.db')
    db.delete_commit_by_id(commit_id=int(entry_id))

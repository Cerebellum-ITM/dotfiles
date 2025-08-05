import sys
from db_manager import TranslationDB


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: python query_commits.py <execute_path>')
        sys.exit(1)

    execute_path = sys.argv[1]
    filter_by = None
    if execute_path != 'no':
        filter_by = {'execute_path': execute_path}

    db = TranslationDB('~/dotfiles/home/.config/.tmp/fzf-translate_history.db')
    commits = db.query_commits(filter_by=filter_by)

    if commits:
        print(commits)
    else:
        print('No recordss found')

import sys
from db_manager import TranslationDB


def get_all_commits(execute_path: str, db: TranslationDB) -> None:
    filter_by = None
    if execute_path != 'no':
        filter_by = {'execute_path': execute_path}

    commits = db.query_commits(filter_by=filter_by)

    if commits:
        for commit in reversed(commits):
            print(f'{commit[0]}\t{commit[1]}\t{commit[2]}\t{commit[3]}\t{commit[4]}')
    else:
        print('No records found')


def get_commit_by_id(id: int, db: TranslationDB) -> None:
    error_message = 'Cannot get translate message with that ID'
    if id == 0:
        print(error_message)
    commit = db.get_translation_by_id(commit_id=id)
    if commit:
        print(commit)
    else:
        print(error_message)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: python query_commits.py <execute_path>')
        sys.exit(1)

    db = TranslationDB('~/dotfiles/home/.config/.tmp/fzf-translate_history.db')

    command = sys.argv[1]
    if command == 'get_all_commits':
        get_all_commits(execute_path=sys.argv[2], db=db)
    elif command == 'get_commit_by_id':
        get_commit_by_id(id=int(sys.argv[2]), db=db)
    else:
        print(f'Unknown command: {command}')
        sys.exit(1)

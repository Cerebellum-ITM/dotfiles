import os
import sys
import argparse

from groq import Groq
from rich import print
from dotenv import load_dotenv


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
def translate_commit_message(commit_message: str) -> str:
    dotenv_path = os.path.expanduser('~/dotfiles/python/.env')
    load_dotenv(dotenv_path)

    client = Groq(
        api_key=os.environ.get('GROQ_API_KEY'),
    )

    system_prompt = """
        Translate the following Git commit message from Spanish to English. The message was written by a developer with extensive experience. Ensure the translation maintains technical context and precision, while keeping the translated message between 80 and 150 characters.
    """

    try:
        completion = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': system_prompt,
                },
                {'role': 'user', 'content': commit_message},
            ],
            model='llama-3.3-70b-versatile',
        )
        content = completion.choices[0].message.content

        if content is None:
            raise ValueError('Received None instead of a valid translated message.')

        if content.startswith('"') and content.endswith('"'):
            content = content[1:-1]

        return content

    except Exception as e:
        print(f'[red]Error translating commit message: {e}[/red]')
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Translate Git commit messages from Spanish to English.'
    )
    parser.add_argument('message', type=str, help='The commit message to translate')

    args = parser.parse_args()
    translated_message = translate_commit_message(args.message)
    print(translated_message)


if __name__ == '__main__':
    main()

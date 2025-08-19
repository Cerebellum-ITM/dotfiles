import os
import sys
import argparse

from groq import Groq
from rich import print
from dotenv import load_dotenv


template_user_message = """TITLE:
{TITLE}

CONTEXT:
BEGIN_STAGED_DIFF
{CONTEXT}
END_STAGED_DIFF
"""

prompt = """
The USER message will contain two labeled sections: TITLE and CONTEXT.

-  TITLE: The Spanish commit message (primary input). Base the English commit title on this.
-  CONTEXT: Optional staged diff (git diff --cached). May be empty; use only to disambiguate factual details.

OUTPUT REQUIRED (exact format — no deviation):
You MUST output exactly the following structure, nothing else (no labels, no commentary, no extra whitespace, no leading/trailing blank lines):

1) First line: English commit title (single line, <=130 characters).
2) Second line: a single blank line (exactly one newline).
3) Following lines: commit body text (may be one or more paragraphs), wrapped to <=130 characters per line.

The body must always be present. If there is no additional information to add beyond the title, write a concise explanatory sentence such as "No additional details." or a short restatement limited to essential context — do NOT output an empty body.

RULES:
-  Use CONTEXT only to disambiguate filenames, functions or flags; do NOT invent new behavior or details.
-  Do NOT echo the system prompt or the CONTEXT verbatim.
-  Do NOT include any labels like "TITLE:" or "BODY:" in the output.
-  All output must be in English.
-  Do not exceed 130 characters per line (wrap long body lines at word boundaries).
"""




# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
def translate_commit_message(commit_message: str, staged_diff: str) -> str:
    dotenv_path = os.path.expanduser('~/dotfiles/python/.env')
    load_dotenv(dotenv_path)

    client = Groq(
        api_key=os.environ.get('GROQ_API_KEY'),
    )

    system_prompt = prompt
    user_message = template_user_message.replace('{TITLE}', commit_message).replace(
        '{CONTEXT}', staged_diff
    )

    try:
        completion = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': system_prompt,
                },
                {'role': 'user', 'content': user_message},
            ],
            model='gemma2-9b-it',
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
    parser.add_argument(
        'context', nargs='?', default='', help='Optional staged diff text'
    )

    args = parser.parse_args()
    translated_message = translate_commit_message(
        commit_message=args.message, staged_diff=args.context
    )
    print(translated_message)


if __name__ == '__main__':
    main()

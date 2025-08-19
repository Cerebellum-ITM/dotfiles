import os
import sys
import argparse

from groq import Groq
from rich import print
from dotenv import load_dotenv


prompt = """Translate the following Git commit message from Spanish to English. The author is a senior developer; keep technical context and precision. Produce only the final commit text in English. Do NOT include labels, JSON, commentary, or any other text.

Core rules (mandatory):
-  Do NOT invent facts, endpoints, commands, examples, or any information not present or clearly implied by the original Spanish message.
-  Avoid redundancy: do not repeat information already contained in the title inside the body. If the title fully conveys the commit meaning, do NOT output a body — return only the TITLE_LINE (see Output rules below).
-  Title must be concise, factual and not redundant with the body.
-  All output must be in English.

Generation requirements:
1) Title (single line): produce a single-line title, up to 130 characters, with no line breaks and never split words. Prioritize relevant keywords present in the source (languages, tools/CLIs/libraries, purposes/contexts, components/scopes). If a literal translation exceeds 130 chars, rewrite concisely (use synonyms, reorder, shorten non-critical words) but do NOT invent new facts.

2) Body (optional): produce the explanatory body only if the Spanish message contains additional details that cannot be conveyed in a concise title. If included, first produce the body as a single continuous paragraph (NO newline characters at this stage). Preserve code, function names, file paths, commands, flags, and variable names exactly as they appear.

Formatting rules (if body is present):
3) Wrap the body to lines of at most 130 characters. Wrap at word boundaries; do NOT split words. Preserve indentation for list items/bullets; do not reflow inside code blocks or inline code. If a token (URL/path) exceeds 130 characters, place it on its own line.

Decision rule (whether to include a body):
-  If the title can fully and accurately represent the commit (no loss of essential detail), DO NOT include a body — return only the TITLE_LINE.
-  If the Spanish message includes important additional context (what/why/how) that the title cannot contain without exceeding 130 characters, include a concise body. Do not add details beyond what the original message provides.

Strict output rules (choose one of the two formats exactly):
A) If NO body is necessary:
<TITLE_LINE (single line, <=130 chars)>
(End — no blank line, no body.)

B) If a body is necessary:
<TITLE_LINE (single line, <=130 chars)>

<WRAPPED_BODY (lines <= 130 chars, no word splits, no extra blank lines)>

Additional constraints:
-  Do not invent or hallucinate. If information is missing, prefer omitting the body rather than adding assumptions.
-  Do not be redundant: information in the title should not be repeated verbatim in the body.
-  Ensure exactly one blank line between title and body when a body is present; otherwise return only the title line.
-  No trailing spaces at line ends.
-  All output must be in English.

Input:
<SPANISH_COMMIT_MESSAGE>
"""


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
def translate_commit_message(commit_message: str) -> str:
    dotenv_path = os.path.expanduser('~/dotfiles/python/.env')
    load_dotenv(dotenv_path)

    client = Groq(
        api_key=os.environ.get('GROQ_API_KEY'),
    )

    system_prompt = prompt

    try:
        completion = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': system_prompt,
                },
                {'role': 'user', 'content': commit_message},
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

    args = parser.parse_args()
    translated_message = translate_commit_message(args.message)
    print(translated_message)


if __name__ == '__main__':
    main()

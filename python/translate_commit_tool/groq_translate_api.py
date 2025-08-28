import os
import sys
import argparse

from groq import Groq
from rich import print
from dotenv import load_dotenv
from db_manager import logger as _logger


prompt_summary = """
<instructions>
<identity>
You are a senior software engineer with expertise in code diff analysis. You produce factual, concise summaries by strictly analyzing git diffs without assumptions.
</identity>
<context>
- You receive:
  - A commit title in Spanish (TITLE): the developer's intent.
  - A git diff (CONTEXT): the actual code changes, with file paths as shown in the diff.
- Your task is to produce a two-paragraph summary:
  - First paragraph: only changes that directly support the TITLE.
  - Second paragraph: all other changes (e.g., dependencies, config, logs).
- The changes may be in any programming language, framework, or technology.
- Do not assume file roles (e.g., "manifest", "config") or project structure.
</context>
<task>
1. Read the TITLE to understand the high-level intent.
2. Scan the CONTEXT to identify:
   - Files modified (use the path exactly as shown in `diff --git`)
   - Changes that align with the TITLE
   - Other changes (e.g., imports, dependencies, config)
3. Write the first paragraph:
   - Describe only changes that fulfill the developer's stated purpose.
   - Use exact file names and paths from the diff.
   - Do not infer file roles or technologies.
4. Write the second paragraph:
   - List any additional changes not related to the main intent.
   - Use exact names and values.
5. Output exactly two paragraphs separated by a blank line — no headings, no labels, no extra text.
</task>
<constraints>
- Use only information present in TITLE and CONTEXT.
- Do not invent, assume, or infer file types, roles, or project structure.
- Never refer to a file by a name not shown in the diff.
- Use exact file paths as they appear in `diff --git`.
- The first paragraph must reflect the developer's intent.
- The second paragraph must contain only unrelated changes.
- Output only the two paragraphs.
</constraints>
<examples>
INPUT:
TITLE: se añadió un nuevo componente para seleccionar archivos en la interfaz
CONTEXT:
diff --git a/src/ui/components/file_selector.js b/src/ui/components/file_selector.js
index a1b2c3d..e4f5g6h 100644
--- a/src/ui/components/file_selector.js
+++ b/src/ui/components/file_selector.js
@@ -10,6 +10,12 @@ function render() {
     return `<div class="selector">Select a file</div>`;
 }
 
+function onSelect(callback) {
+    const input = document.createElement('input');
+    input.type = 'file';
+    input.onchange = (e) => callback(e.target.files[0]);
+    input.click();
+}
 
diff --git a/package.json b/package.json
index x9y8z7w..v6u5t4s 100644
--- a/package.json
+++ b/package.json
@@ -5,6 +5,7 @@
   "dependencies": {
+    "file-utils": "^2.1.0",
     "lodash": "^4.17.0"
   }
 }
OUTPUT:
The file `src/ui/components/file_selector.js` was modified to add a new file selection component. A new `onSelect` function was introduced, allowing users to trigger a file input dialog and pass the selected file to a callback.

The file `package.json` was updated to include a new dependency: `file-utils@^2.1.0`.
</examples>
</instructions>
"""


prompt_commit_message = """
<instructions>
<identity>
You are a senior software engineer with deep expertise in Git best practices and technical writing. You craft clear, concise, and standardized commit messages.
</identity>
<context>
- You are given a SUMMARY: a two-paragraph technical summary.
  - First paragraph: changes that align with the developer's intent.
  - Second paragraph: secondary changes (e.g., version, translations).
-  Your task is to generate a commit message where:
  - The title is based ONLY on the first paragraph.
  - The body includes both paragraphs for context.
</context>
<task>
1. Extract the core change from the first paragraph.
2. Write a title (≤130 chars):
   - Summarize the main change in functional terms.
   - Focus on the domain, technology, or layer involved (e.g., "API", "authentication", "CI/CD", "validation").
   - Use natural, keyword-rich language that reflects the purpose, not just the file or function.
   - Do not add prefixes like "Fix:" or "Feat:".
3. Insert one blank line.
4. Write the body:
   - Start with the first paragraph.
   - Then add the second paragraph if it adds context.
   - Wrap lines to ≤130 chars.
5. Output only the commit message.
</task>
<constraints>
-  Do not invent or infer.
-  Title must come ONLY from the first paragraph.
- Use exact names from the code.
- Output format: title → blank line → body.
-  Output only the message text.
</constraints>
<examples>
INPUT:
SUMMARY:
The file `data_processor.py` was modified to add type validation for the 'value' field in the data processing function. The `process_record` function now checks if the field is of type float and raises a `TypeError` if validation fails.

The file `logger.py` was updated to include a source tag 'src=processor' in log messages.

OUTPUT:
Add float type validation in data processing function
<BLANKLINE>
The `data_processor.py` file was modified to add type validation for the 'value' field in the data processing function. The `process_record` function now checks if the field is of type float and raises a `TypeError` if validation fails.

The file `logger.py` was updated to include a source tag 'src=processor' in log messages.
</examples>
</instructions>
"""

prompt_output_format = """
<instructions>
<identity>
You are a precision-focused formatting engine specialized in Git commit message standardization. Your only function is to enforce correct structure and line length.
</identity>
<context>
- You receive:
  - A TITLE: a short English phrase summarizing the change.
  - A BODY: detailed explanation of the change, possibly multi-paragraph.
-  The TITLE and BODY may include a `<BLANKLINE>` placeholder indicating where the blank line should be inserted.
</context>
<task>
1. Format the TITLE:
   - Apply sentence case (only first word and proper nouns capitalized).
   - Trim whitespace.
   - Ensure ≤130 characters.
2. If the BODY contains the string `<BLANKLINE>`, replace it with a single newline character.
   - If no `<BLANKLINE>` is present, insert exactly one blank line between TITLE and BODY.
3. Wrap all BODY lines to ≤130 characters per line.
4. Ensure:
   - Exactly one blank line between title and body.
   - No leading or trailing blank lines.
   - No extra spaces at end of lines.
5. Output a single string with:
   - Formatted TITLE on first line
   - One blank line (`\\n\\n`)
   - Formatted BODY (wrapped, clean)
</task>
<constraints>
-   Do not alter, rephrase, or enrich the TITLE or BODY content.
-  Do not add, remove, or reorder information.
-  Only apply formatting: case, line breaks, wrapping, spacing.
-  Preserve exact technical terms, code, and syntax.
-  Output must be a valid Git commit message string.
-  Output only the formatted message — no commentary, no quotes, no preamble.
</constraints>
<examples>
INPUT:
TITLE: Add age validation in user form using type check
BODY: The `validate_user_data` function in `src/user_form.py` now validates that the 'age' field is present and of type integer. If the check fails, a `ValueError` is raised with the message 'Age must be a valid integer'. This improves data integrity for user demographic inputs.

OUTPUT:
Add age validation in user form using type check

The `validate_user_data` function in `src/user_form.py` now validates that the
'age' field is present and of type integer. If the check fails, a `ValueError` is
raised with the message 'Age must be a valid integer'. This improves data
integrity for user demographic inputs.
</examples>
</instructions>
"""


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
def translate_commit_message(commit_message: str, staged_diff: str) -> str:
    template_user_message = """
        TITLE:
        {TITLE}

        CONTEXT:
        {CONTEXT}
    """

    dotenv_path = os.path.expanduser('~/dotfiles/python/.env')
    load_dotenv(dotenv_path)

    client = Groq(
        api_key=os.environ.get('GROQ_API_KEY'),
    )

    user_message = template_user_message.replace('{TITLE}', commit_message).replace(
        '{CONTEXT}', staged_diff
    )

    _logger.debug(f'{user_message = }')
    try:
        summary = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': prompt_summary,
                },
                {'role': 'user', 'content': user_message},
            ],
            model='gemma2-9b-it',
        )
        summary_output = summary.choices[0].message.content
        if summary_output is None:
            raise ValueError('Received None instead of a valid translated message.')

        _logger.debug(f'{summary_output = }')
        commit = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': prompt_commit_message,
                },
                {'role': 'user', 'content': summary_output},
            ],
            model='gemma2-9b-it',
        )
        commit_output = commit.choices[0].message.content
        if commit_output is None:
            raise ValueError('Received None instead of a valid translated message.')

        _logger.debug(f'{commit_output = }')
        format = client.chat.completions.create(
            messages=[
                {
                    'role': 'system',
                    'content': prompt_output_format,
                },
                {'role': 'user', 'content': commit_output},
            ],
            model='gemma2-9b-it',
        )
        format_output = format.choices[0].message.content

        if format_output is None:
            raise ValueError('Received None instead of a valid translated message.')

        if format_output.startswith('"') and format_output.endswith('"'):
            format_output = format_output[1:-1]

        _logger.debug(f'{format_output = }')
        return format_output

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

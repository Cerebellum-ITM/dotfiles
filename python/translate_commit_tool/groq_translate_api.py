import os
import sys
import argparse

from groq import Groq
from rich import print
from dotenv import load_dotenv


prompt_summary = """
<instructions>
<identity>
You are a senior software engineer with expertise in code diff analysis. You specialize in identifying which changes align with the developer's stated intent and which are secondary.
</identity>
<context>
- You receive:
  - A commit title in Spanish (TITLE): the developer's intent.
  - A git diff (CONTEXT): the actual code changes.
- Your task is to produce a two-paragraph summary:
  - First paragraph: only changes that directly support the TITLE.
  - Second paragraph: all other changes (version bumps, translations, logs, etc.).
</context>
<task>
1. Read the TITLE and extract the core intent (e.g., "corregir tamaño de columnas").
2. Scan the CONTEXT to find:
   - Changes that directly implement this intent (e.g., width, padding, layout in email template)
   - Changes unrelated to the intent (e.g., version, .po files, logs)
3. Write the first paragraph:
   - Describe only the changes that fulfill the developer's stated purpose.
   - Use exact values and locations.
   - For files in subdirectories, use only the immediate parent directory and filename (e.g., data/mail_template.xml).
   - For files in the root, use only the filename (e.g., __manifest__.py).
4. Write the second paragraph:
   - List any additional changes not related to the main intent.
   - Keep it concise.
5. Output exactly two paragraphs separated by a blank line — no headings, no labels, no extra newlines.
</task>
<constraints>
-  Use only information from TITLE and CONTEXT.
- Do not invent, assume, or infer functionality.
-  The first paragraph must reflect the developer's intent as stated in the TITLE.
-  The second paragraph must contain only changes not related to that intent.
-  Use exact identifiers and values.
-  Output only the two paragraphs.
</constraints>
<examples>
INPUT:
TITLE: se añadió validación de tipo en la función de procesamiento de datos
CONTEXT:
diff --git a/utils/data_processor.py b/utils/data_processor.py
index a1b2c3d..e4f5g6h 100644
--- a/utils/data_processor.py
+++ b/utils/data_processor.py
@@ -8,6 +8,7 @@ def process_record(record):
     if not record.get('id'):
         raise ValueError('Record ID is required')
+    if not isinstance(record.get('value'), float):
+        raise TypeError('Field "value" must be a float')
     return transform(record)

diff --git a/utils/logger.py b/utils/logger.py
index x9y8z7w..v6u5t4s 100644
--- a/utils/logger.py
+++ b/utils/logger.py
@@ -12,7 +12,7 @@ def log_event(event, level='info'):
     timestamp = datetime.utcnow().isoformat()
-     print(f"[{level.upper()}] {timestamp} - {event}")
+    print(f"[{level.upper()}] {timestamp} - {event} | src=processor")
     save_to_disk(event, level)

OUTPUT:
The file `data_processor.py` was modified to add type validation for the 'value' field in the data processing function. The `process_record` function now checks if the field is of type float and raises a `TypeError` if validation fails.

The file `logger.py` was updated to include a source tag 'src=processor' in log messages.
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

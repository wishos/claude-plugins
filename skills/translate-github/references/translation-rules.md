# Translation Rules

Translation target: translate English documentation into high-quality Chinese documentation. Strictly follow these rules:

## Content That Must Be Translated

- Body paragraphs
- Headings (all levels of `#` headings)
- List item text
- Text content in tables
- Image alt text
- Text in blockquotes (`>` blocks)
- Text in notes / warning boxes

## Content That Must Never Be Translated

- **Code blocks**: Keep ` ``` ` wrapped code blocks entirely intact, including comments in the code
- **Inline code**: Keep `` ` `` wrapped content as-is
- **URLs and link addresses**: Keep original URLs, but translate link text
- **Named identifiers**: variable names, function names, class names, file names, command names
- **Brand names and proper nouns**: such as GitHub, Docker, Kubernetes (may annotate Chinese meaning in parentheses on first occurrence)
- **File paths**: such as `/etc/config.yaml`
- **Version numbers**: such as v1.2.3

## Format Preservation Rules

- Preserve original Markdown format structure (heading levels, list indentation, table alignment)
- Preserve original line breaks and blank lines
- Preserve original link format: `[translated text](original URL)`
- Preserve front matter (YAML header) keys unchanged, only translate values
- Preserve HTML tags unchanged

## Translation Style

- Use natural, fluent Chinese; avoid translationese
- For technical terms, annotate original English in parentheses on first occurrence, e.g. "dependency injection (Dependency Injection)"
- Subsequent occurrences may use Chinese directly
- Maintain professionalism and accuracy

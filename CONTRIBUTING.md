# Contributing

Keep plugin small, predictable, and easy to review.

## Rules

- Target Zsh behavior only.
- Keep scope on `python -m` completion.
- Prefer shell builtins and standard Python library.
- Keep functions private with `_python_m_` prefix.
- Avoid network calls, caches, and heavy startup work.
- Make changes pass ShellCheck and `zsh -n`.
- Update README when behavior changes.

## Pull Requests

- Describe user problem first.
- Add small reproducible example.
- Keep patches focused.
- Do not mix refactor and feature work without reason.
- Preserve license headers and repository metadata.

## Test Notes

Run:

```sh
zsh -n zsh-python-m-completion.plugin.zsh
shellcheck zsh-python-m-completion.plugin.zsh
```

Manual check:

```sh
source zsh-python-m-completion.plugin.zsh
python -m json.<TAB>
python3 -m unittest<TAB>
```
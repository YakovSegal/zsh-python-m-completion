# zsh-python-m-completion

Zsh plugin for `python -m` and `python3 -m` completion.

It completes module names from active interpreter, including dotted submodules like `json.tool`.

## Why

Zsh file completion is good for paths, not Python module names.

This plugin asks selected Python interpreter for importable modules, then offers module completion where `-m` expects it.

## Features

- Completes top-level installed modules.
- Completes dotted submodules after `package.` prefix.
- Uses current interpreter from command line: `python`, `python3`, `python3.12`, and similar names.
- Keeps fallback file completion outside module slot.
- Uses only Zsh plus Python standard library.

## Design

- Detect last `-m` in current command line.
- Complete only argument right after that flag.
- Query interpreter with `pkgutil.iter_modules()`.
- If current word contains dot, import parent package and list direct submodules.
- Return plain module names to Zsh completion system.

This keeps plugin small and avoids hard-coded search paths.

## Install

### Manual

Copy [zsh-python-m-completion.plugin.zsh](zsh-python-m-completion.plugin.zsh) into plugin path and source it from `.zshrc`.

```zsh
source /path/to/zsh-python-m-completion.plugin.zsh
```

### Antidote

```txt
your-name/zsh-python-m-completion
```

### zinit

```zsh
zinit light your-name/zsh-python-m-completion
```

## Usage

```zsh
python -m json.<TAB>
python3 -m http.<TAB>
python3.12 -m unittest<TAB>
```

Examples:

- `python -m json.<TAB>` -> `json.tool`
- `python -m http.<TAB>` -> `http.server`

## Limits

- Submodule completion imports parent package. Packages with import side effects may behave badly.
- Completion shows direct children for dotted prefix, not full recursive tree in one step.
- Outside `-m` module slot, fallback stays file-based.

## Development

Check syntax:

```sh
zsh -n zsh-python-m-completion.plugin.zsh
```

Run ShellCheck if installed:

```sh
shellcheck zsh-python-m-completion.plugin.zsh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for patch rules.

## License

MIT. See [LICENSE](LICENSE).

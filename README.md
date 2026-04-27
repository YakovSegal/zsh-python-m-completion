# zsh-python-m-completion

Zsh plugin for `python -m` and `python3 -m` completion.

It completes module names from active interpreter, including dotted submodules like `json.tool`.

Repository: `YakovSegal/zsh-python-m-completion`

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

This repository follows normal Zsh plugin layout: file name matches repository name, so most plugin managers load it without extra config.

### Oh My Zsh

Clone plugin into custom plugins directory:

```sh
git clone https://github.com/YakovSegal/zsh-python-m-completion.git \
	${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-python-m-completion
```

Add plugin to `.zshrc`:

```zsh
plugins=(... zsh-python-m-completion)
```

Restart shell or run:

```zsh
source ~/.zshrc
```

### Manual

Clone repository anywhere and source plugin file from `.zshrc`.

```sh
git clone https://github.com/YakovSegal/zsh-python-m-completion.git ~/.zsh/zsh-python-m-completion
```

```zsh
source ~/.zsh/zsh-python-m-completion/zsh-python-m-completion.plugin.zsh
```

### Antigen

```zsh
antigen bundle YakovSegal/zsh-python-m-completion
```

### Antidote

```txt
YakovSegal/zsh-python-m-completion
```

### zinit

```zsh
zinit light YakovSegal/zsh-python-m-completion
```

### zplug

```zsh
zplug "YakovSegal/zsh-python-m-completion"
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

If completion does not appear, reload shell with `source ~/.zshrc` and make sure plugin loads after `compinit`.

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

## Release Notes

For easy public install:

- Keep repository public on GitHub.
- Keep main plugin file named `zsh-python-m-completion.plugin.zsh`.
- Tag releases like `v0.1.0` when behavior changes.
- Do not rename repository without updating install snippets.

## License

MIT. See [LICENSE](LICENSE).

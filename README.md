# zsh-python-m-completion

Zsh plugin for `python -m` module completion.

## Requirements

- Zsh
- Python available as `python`, `python3`, or versioned `python3.x`

## Install

### zplug (recommended)

Install zplug first if needed:

```sh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

Add to `.zshrc`:

```zsh
zplug "YakovSegal/zsh-python-m-completion"
zplug load
```

Reload shell:

```zsh
source ~/.zshrc
```

## Usage

```zsh
python -m json.<TAB>
python3 -m http.<TAB>
python3 -m unittest<TAB>
```

With fzf completion widget bound to Tab:

```zsh
python -m json.<TAB>
python3 -m unit<TAB>
```

## Notes

- Completes top-level modules and dotted submodules.
- Uses current interpreter from command line.
- Outside `-m` argument, normal file completion stays unchanged.
- Works with prefixed commands (for example `wrapper -- python -m ...`).
- fzf mode works from normal Tab binding and supports `python` and `python3`.

## Development

```sh
zsh -n zsh-python-m-completion.plugin.zsh
shellcheck zsh-python-m-completion.plugin.zsh
```

## License

MIT. See [LICENSE](LICENSE).

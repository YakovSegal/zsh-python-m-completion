# zsh-python-m-completion

Zsh plugin for `python -m` module completion.

## Requirements

- Zsh
- Python available as `python`, `python3`, or versioned `python3.x`

## Install

### Oh My Zsh

```sh
git clone https://github.com/YakovSegal/zsh-python-m-completion.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-python-m-completion
```

Add to `.zshrc`:

```zsh
plugins=(... zsh-python-m-completion)
```

Reload shell:

```zsh
source ~/.zshrc
```

### Manual

```sh
git clone https://github.com/YakovSegal/zsh-python-m-completion.git ~/.zsh/zsh-python-m-completion
```

Add to `.zshrc`:

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
python3 -m unittest<TAB>
```

## Notes

- Completes top-level modules and dotted submodules.
- Uses current interpreter from command line.
- Outside `-m` argument, normal file completion stays unchanged.

## Development

```sh
zsh -n zsh-python-m-completion.plugin.zsh
shellcheck zsh-python-m-completion.plugin.zsh
```

## License

MIT. See [LICENSE](LICENSE).

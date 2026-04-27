# zsh-python-m-completion

Zsh plugin for `python -m` module completion with fzf support.

## Requirements

- Zsh
- Python (`python`, `python3`, or `python3.x`)
- [fzf](https://github.com/junegunn/fzf) _(optional, for fuzzy picker)_

## Install

```sh
git clone https://github.com/YakovSegal/zsh-python-m-completion.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-python-m-completion
```

Add to `~/.zshrc`:

```zsh
plugins=(... zsh-python-m-completion)
```

Reload:

```zsh
source ~/.zshrc
```

## Usage

Tab-complete module name after `-m`:

```zsh
python -m uni<TAB>
# → unittest

python3 -m http.s<TAB>
# → http.server

doppler run -- python -m mymod<TAB>
# → mymodule
# → mymodule.sub_module_1  mymodule.sub_module_2 ...
```

With fzf bound to Tab — fuzzy picker opens automatically:

```zsh
python -m mymod<TAB>
# fzf list opens → pick → inserted with dot if submodules exist
```

## Notes

- Works with any wrapper prefix (`doppler run --`, `env VAR=x --`, etc.).
- Dot suffix auto-appended when module has submodules.
- Outside `-m`, normal completion unchanged.

## Development

```sh
zsh -n zsh-python-m-completion.plugin.zsh
shellcheck zsh-python-m-completion.plugin.zsh
```

## License

MIT. See [LICENSE](LICENSE).

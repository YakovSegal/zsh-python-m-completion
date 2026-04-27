# shellcheck shell=bash disable=SC2154
# zsh-python-m-completion.plugin.zsh
_python_m_list_modules() {
    local python_cmd=$1
    local module_prefix=$2
    local python_code='
import importlib
import pkgutil
import sys

prefix = sys.argv[1]
seen = set()

def emit(names):
    for name in sorted(names):
        if name and name not in seen:
            seen.add(name)
            print(name)

if "." in prefix:
    parent, partial = prefix.rsplit(".", 1)
    try:
        module = importlib.import_module(parent)
    except Exception:
        raise SystemExit(0)

    search_path = getattr(module, "__path__", None)
    if search_path is None:
        raise SystemExit(0)

    emit(
        f"{parent}.{name}"
        for _, name, _ in pkgutil.iter_modules(search_path)
        if name.startswith(partial)
    )
else:
    emit(
        name
        for _, name, _ in pkgutil.iter_modules()
        if name.startswith(prefix)
    )
'

    "$python_cmd" -c "$python_code" -- "$module_prefix" 2>/dev/null
}

_python_m_completion() {
    local module_index=-1
    local index

    for (( index = 1; index <= $#words; index++ )); do
        if [[ ${words[index]} == -m ]]; then
            module_index=$index
        fi
    done

    if (( module_index == -1 || CURRENT != module_index + 1 )); then
        _files
        return 0
    fi

    local python_cmd=${words[1]}
    local module_prefix=${words[CURRENT]}
    local output
    local -a modules

    output=$(_python_m_list_modules "$python_cmd" "$module_prefix") || return 1

    while IFS= read -r module; do
        [[ -n $module ]] && modules+=("$module")
    done <<< "$output"

    if (( $#modules == 0 )); then
        return 1
    fi

    compadd -Q -a modules
}

_python_m_fzf_completion() {
    local line=$1
    local python_cmd=${line%%[[:space:]]*}

    if [[ ! $line =~ (^|[[:space:]])-m[[:space:]]*$ ]]; then
        _fzf_path_completion "$prefix" "$1"
        return
    fi

    local module_prefix=${prefix}

    _fzf_complete -- "$@" < <(_python_m_list_modules "$python_cmd" "$module_prefix")
}

_fzf_complete_python() {
    _python_m_fzf_completion "$@"
}

_fzf_complete_python3() {
    _python_m_fzf_completion "$@"
}

_python_m_register_completion() {
    local compdef_origin

    compdef_origin=$(whence -v compdef 2>/dev/null)
    if [[ $compdef_origin == *zsh-autocomplete* ]]; then
        autoload -Uz compinit
        compinit -i -C 2>/dev/null || compinit -i 2>/dev/null
    fi

    whence -w compdef >/dev/null 2>&1 || return 1
    compdef _python_m_completion python python3 'python<->' 'python<->.<->'
}

_python_m_register_completion

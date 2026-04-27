# shellcheck shell=bash disable=SC2154
# zsh-python-m-completion.plugin.zsh
_python_m_list_modules() {
    local python_cmd=$1
    local module_prefix=$2
    local python_code='
import importlib.util
import pkgutil
import sys

prefix = sys.argv[1] if len(sys.argv) > 1 else ""
seen = set()

def emit(names):
    for name in sorted(names):
        if name and name not in seen:
            seen.add(name)
            print(name)

if "." in prefix:
    parent, partial = prefix.rsplit(".", 1)
    spec = importlib.util.find_spec(parent)
    if spec is None:
        raise SystemExit(0)

    search_path = spec.submodule_search_locations
    if not search_path:
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

    "$python_cmd" -c "$python_code" "$module_prefix" 2>/dev/null
}

_python_m_has_submodules() {
    local python_cmd=$1
    local module_name=$2
    "$python_cmd" - <<PY 2>/dev/null
import importlib.util, pkgutil, sys
spec = importlib.util.find_spec('${module_name}')
if spec is None:
    sys.exit(1)
path = spec.submodule_search_locations
if path and next(pkgutil.iter_modules(path), None):
    sys.exit(0)
sys.exit(1)
PY
}

_python_m_completion() {
    local module_index=-1
    local python_index=-1
    local index

    for (( index = 1; index <= $#words; index++ )); do
        if [[ ${words[index]} == -m ]]; then
            module_index=$index
        fi
    done

    if (( module_index == -1 || CURRENT != module_index + 1 )); then
        if [[ $service == python* ]]; then
            _default
            return
        fi
        return 1
    fi

    for (( index = module_index - 1; index >= 1; index-- )); do
        if [[ ${words[index]} == python* || ${words[index]} == python[0-9]* ]]; then
            python_index=$index
            break
        fi
    done

    local python_cmd
    if (( python_index >= 1 )); then
        python_cmd=${words[python_index]}
    else
        python_cmd=python
    fi

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

    local -a suffix_opts
    if (( $#modules == 1 )); then
        if _python_m_has_submodules "$python_cmd" "${modules[1]}"; then
            suffix_opts=(-S '.')
        else
            suffix_opts=(-S ' ')
        fi
    fi

    compadd -Q "${suffix_opts[@]}" -a modules
    return 0
}

_python_m_fzf_completion_post() {
    local module=${1-}
    if [[ -z $module ]]; then
        IFS= read -r module || return 1
    fi
    [[ -n $module ]] || return 1
    local python_cmd=${_python_m_active_cmd:-python}
    if _python_m_has_submodules "$python_cmd" "$module"; then
        printf '%s.' "$module"
    else
        printf '%s' "$module"
    fi
}

_python_m_extract_python_cmd() {
    local line=$1
    local m_pos word python_cmd
    python_cmd=''
    local -a parts
    read -rA parts <<< "$line"
    local i
    for (( i = ${#parts[@]}; i >= 1; i-- )); do
        if [[ ${parts[i]} == -m ]]; then
            m_pos=$i
            break
        fi
    done
    if [[ -n $m_pos ]]; then
        for (( i = m_pos - 1; i >= 1; i-- )); do
            word=${parts[i]}
            if [[ $word == python* ]]; then
                python_cmd=$word
                break
            fi
        done
    fi
    [[ -n $python_cmd ]] || python_cmd=python
    printf '%s' "$python_cmd"
}

_python_m_fzf_completion() {
    local line=$1

    if [[ ! $line =~ (^|[[:space:]])-m[[:space:]]*$ ]]; then
        _fzf_path_completion "$prefix" "$1"
        return
    fi

    local python_cmd
    python_cmd=$(_python_m_extract_python_cmd "$line")

    local module_prefix=${prefix}
    local module_output

    module_output=$(_python_m_list_modules "$python_cmd" "$module_prefix") || return 1
    [[ -n $module_output ]] || return 1

    _python_m_active_cmd=$python_cmd
    _fzf_complete --no-multi -- "$@" < <(printf '%s\n' "$module_output")
    unset _python_m_active_cmd
}

_fzf_complete_python() {
    _python_m_fzf_completion "$@"
}

_fzf_complete_python_post() {
    _python_m_fzf_completion_post "$@"
}

_fzf_complete_python3() {
    _python_m_fzf_completion "$@"
}

_fzf_complete_python3_post() {
    _python_m_fzf_completion_post "$@"
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
    compdef -p _python_m_completion '*'
}

_python_m_tab_widget() {
    local line=${LBUFFER}

    if [[ $line =~ python[^[:space:]]*[[:space:]]+-m([[:space:]]+[^[:space:]]+)?[[:space:]]*$ ]]; then
        local module_prefix=${line##*[[:space:]]}
        local python_cmd
        python_cmd=$(_python_m_extract_python_cmd "$line")

        local candidates
        candidates=$(_python_m_list_modules "$python_cmd" "$module_prefix" 2>/dev/null)

        if [[ -z $candidates ]]; then
            zle expand-or-complete
            return
        fi

        if whence -w _fzf_complete >/dev/null 2>&1; then
            # Strip any prefix before 'python' so fzf-completion dispatches on python
            local before_python=${line%%python*}
            local from_python=${line#"$before_python"}

            # Temporarily expose only python -m ... to fzf-completion dispatcher
            LBUFFER=$from_python
            local previous_trigger=${FZF_COMPLETION_TRIGGER-'**'}
            FZF_COMPLETION_TRIGGER=''
            zle fzf-completion
            FZF_COMPLETION_TRIGGER=$previous_trigger

            # Restore the stripped prefix, keeping whatever fzf inserted
            LBUFFER="${before_python}${LBUFFER}"
            return
        fi

        zle expand-or-complete
        return
    fi

    if whence -w fzf-completion >/dev/null 2>&1; then
        zle fzf-completion
        return
    fi

    zle expand-or-complete
}

_python_m_register_tab_widget() {
    whence -w zle >/dev/null 2>&1 || return 0

    if [[ $(bindkey '^I' 2>/dev/null) == *fzf-completion* ]]; then
        zle -N _python_m_tab_widget
        bindkey '^I' _python_m_tab_widget
    fi
}

_python_m_register_completion
_python_m_register_tab_widget

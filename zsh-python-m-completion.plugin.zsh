# zsh-python-m-completion.plugin.zsh
_python_m_completion() {
    local module_index=-1
    local index

    for index in {1..$#words}; do
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
    local output
    local -a modules

    output=$("$python_cmd" -c "$python_code" -- "$module_prefix" 2>/dev/null) || return 1
    modules=(${(f)output})

    if (( $#modules == 0 )); then
        return 1
    fi

    compadd -Q -a modules
}

compdef _python_m_completion python python3 'python<->' 'python<->.<->'

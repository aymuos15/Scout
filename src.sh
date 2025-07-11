alias bat='batcat'
show() {
    find . -type f ! -path "*/__pycache__/*" ! -name "__init__.py" ! -path "*/.*" ! -path "*/*.egg-info/*" | fzf --preview "batcat --style=numbers --color=always {}" --preview-window=right:70% --layout=reverse --height=100% --border --info=inline --bind "f2:abort" --expect=f2
}

search() {
    rg --line-number --no-heading --color=always --smart-case . | fzf --ansi --preview 'file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); start=$((line > 20 ? line - 20 : 1)); batcat --style=numbers --color=always --line-range $start: --highlight-line $line "$file" 2>/dev/null || batcat --style=numbers --color=always --line-range $start: "$file"' --preview-window=right:70% --layout=reverse --height=100% --border --info=inline --delimiter=: --nth=3.. --bind "f2:abort" --expect=f2
}

browse() {
    local mode="show"
    while true; do
        if [[ "$mode" == "show" ]]; then
            local output=$(show)
            local exit_code=$?
            # Check if F2 was pressed (first line of output will be "f2")
            if [[ "$output" == "f2"* ]]; then
                mode="search"
            else
                # Normal exit or ESC
                break
            fi
        else
            local output=$(search)
            local exit_code=$?
            # Check if F2 was pressed
            if [[ "$output" == "f2"* ]]; then
                mode="show"
            else
                # Normal exit or ESC
                break
            fi
        fi
    done
}

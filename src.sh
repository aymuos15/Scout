# Alias for batcat, a syntax-highlighting pager
alias bat='batcat'

# Function to display files in the current directory using fzf with a preview
show() {
    # Find all files excluding certain paths and file types, then use fzf for interactive selection
    find . -type f \
        ! -path "*/__pycache__/*" \
        ! -name "__init__.py" \
        ! -path "*/.*" \
        ! -path "*/*.egg-info/*" \
        | fzf --preview "batcat --style=numbers --color=always {}" \
               --preview-window=right:70% \
               --layout=reverse \
               --height=100% \
               --border \
               --info=inline \
               --bind "f2:abort" \
               --expect=f2
}

# Function to search for text in files using ripgrep and fzf with a preview
search() {
    # Use ripgrep to search for text, then use fzf for interactive selection with a preview
    rg --line-number --no-heading --color=always --smart-case . \
        | fzf --ansi \
               --preview 'file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); start=$((line > 20 ? line - 20 : 1)); batcat --style=numbers --color=always --line-range $start: --highlight-line $line "$file" 2>/dev/null || batcat --style=numbers --color=always --line-range $start: "$file"' \
               --preview-window=right:70% \
               --layout=reverse \
               --height=100% \
               --border \
               --info=inline \
               --delimiter=: \
               --nth=3.. \
               --bind "f2:abort" \
               --expect=f2
}

# Function to toggle between 'show' and 'search' modes using fzf
browse() {
    local mode="show"  # Start in 'show' mode
    while true; do
        if [[ "$mode" == "show" ]]; then
            # Call the 'show' function and capture its output
            local output=$(show)
            local exit_code=$?
            # If F2 was pressed, switch to 'search' mode
            if [[ "$output" == "f2"* ]]; then
                mode="search"
            else
                # Exit the loop on normal exit or ESC
                break
            fi
        else
            # Call the 'search' function and capture its output
            local output=$(search)
            local exit_code=$?
            # If F2 was pressed, switch back to 'show' mode
            if [[ "$output" == "f2"* ]]; then
                mode="show"
            else
                # Exit the loop on normal exit or ESC
                break
            fi
        fi
    done
}

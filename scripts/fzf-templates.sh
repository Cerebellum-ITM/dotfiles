_fzf_templates_gui() {
    fzf-tmux --ansi	-m -p80%,60% -- \
        --layout=reverse --multi --height=50% --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,80%,border-left' \
        --preview="tree -C $HOME/dotfiles/templates/odoo/{}"
}

_odoo_template_list() {
    BASE_DIR="$HOME/dotfiles/templates/odoo"
    SELECTED_DIR=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | _fzf_templates_gui)
    cookiecutter $HOME/dotfiles/templates/odoo/$SELECTED_DIR
}

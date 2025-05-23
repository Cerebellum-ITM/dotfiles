# shellcheck shell=bash
_fzf_templates_gui() {
    fzf-tmux --ansi -m -p80%,60% -- \
        --layout=reverse --multi --height=50% --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,80%,border-left' \
        --cycle \
        --header='Select the template to use' \
        --preview="eza --tree --color=always --icons $HOME/dotfiles/templates/odoo/{}"
}

_odoo_template_list() {
    BASE_DIR="$HOME/dotfiles/templates/odoo"
    SELECTED_DIR=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | _fzf_templates_gui) || return 1
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        echo "$(red_bold 'DOCKER_COMPOSE_CMD is not set in ~/.docker-compose-config')"
        read -n 1 -s -r -p "Press any key to continue"
        exit 1
    fi

    if [ "$SELECTED_DIR" = "makefile_template" ]; then
        ODOO_CONTAINER_NAME=$(eval "$DOCKER_COMPOSE_CMD ps" | fzf --header-lines=1 --header='Select the name of: Odoo Container' --layout=reverse --color='header:italic:underline:red,label:green' --preview-window=hidden | awk '{print $1}')
        DB_CONTAINER_NAME=$(eval "$DOCKER_COMPOSE_CMD ps" | fzf --header-lines=1 --header='Select the name of: Db Container' --layout=reverse --color='header:italic:underline:yellow,label:green' --preview-window=hidden | awk '{print $1}')
        TEMPLATE_FILE="$BASE_DIR/$SELECTED_DIR/Makefile"
        OUTPUT_FILE="Makefile"
        cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -e "s/{{ cookiecutter.odoo_container }}/$ODOO_CONTAINER_NAME/g" \
                -e "s/{{ cookiecutter.db_container }}/$DB_CONTAINER_NAME/g" \
                -e "s/{{ cookiecutter.docker_compose_cmd }}/$DOCKER_COMPOSE_CMD/g" \
                "$OUTPUT_FILE"
        else
            sed -i -e "s/{{ cookiecutter.odoo_container }}/$ODOO_CONTAINER_NAME/g" \
                -e "s/{{ cookiecutter.db_container }}/$DB_CONTAINER_NAME/g" \
                -e "s/{{ cookiecutter.docker_compose_cmd }}/$DOCKER_COMPOSE_CMD/g" \
                "$OUTPUT_FILE"
        fi
    elif [ "$SELECTED_DIR" = "makefile_server_odoo_template" ]; then
        TEMPLATE_FILE="$BASE_DIR/$SELECTED_DIR/Makefile"
        OUTPUT_FILE="Makefile"
        cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
    else
        cookiecutter "$HOME/dotfiles/templates/odoo/$SELECTED_DIR"
    fi
}


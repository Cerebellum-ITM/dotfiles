#!/bin/bash

# Función para eliminar un archivo o directorio si existe
remove_if_exists() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        echo "Removed $1"
    else
        echo "$1 does not exist"
    fi
}

# Desinstalar oh-my-posh
if [ "STERM PROGRAM" != "Apple_Terminal" ]; then
    echo "Uninstalling oh-my-posh..."
    remove_if_exists "$HOME/dotfiles/zsh/oh-my-posh/prompt_config.toml"
fi

# Desinstalar Zinit
echo "Uninstalling Zinit..."
remove_if_exists "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"

# Restaurar LSCOLORS
echo "Restoring LSCOLORS..."
unset LSCOLORS

# Restaurar PATH
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Restoring PATH..."
    export PATH=$(echo "$PATH" | sed -e "s|$HOME/.local/bin:||")
fi

# Desinstalar plugins de zsh
echo "Uninstalling zsh plugins..."
remove_if_exists "$HOME/.zsh_plugins"

# Eliminar configuraciones de zsh
echo "Removing zsh configurations..."
remove_if_exists "$HOME/.zshrc"
remove_if_exists "$HOME/.zshrc-1"

# Eliminar archivos temporales
echo "Removing temporary files..."
remove_if_exists "/tmp/initial_path"
remove_if_exists "/tmp/fzf_select_multi"

# Eliminar archivos de historial de fzf-translate
echo "Removing fzf-translate history..."
remove_if_exists "$HOME/dotfiles/zsh/.fzf-translate_history.log"

# Eliminar archivos de historial de fzf-make
echo "Removing fzf-make history..."
remove_if_exists "$HOME/dotfiles/zsh/.fzf-make_history.log"

# Eliminar scripts personalizados
echo "Removing custom scripts..."
remove_if_exists "$HOME/dotfiles/scripts/odoo.sh"
remove_if_exists "$HOME/dotfiles/scripts/fzf-git.sh"
remove_if_exists "$HOME/dotfiles/scripts/fzf-make.sh"
remove_if_exists "$HOME/dotfiles/scripts/tput-config.sh"
remove_if_exists "$HOME/dotfiles/scripts/fzf-templates.sh"
remove_if_exists "$HOME/dotfiles/scripts/fzf-translate.sh"

# Eliminar configuraciones de Makefile
echo "Removing Makefile configurations..."
remove_if_exists "$HOME/dotfiles/Makefile"
remove_if_exists "$HOME/dotfiles/"
remove_if_exists "$HOME/oh-my-posh"

echo "Uninstallation complete."
#!/bin/bash
# shellcheck disable=SC1091

source "$HOME/dotfiles/tools/gum_styles.sh"
source "$HOME/dotfiles/tools/gum_log_functions.sh"

FILE_NAME="es_MX.po"
MODULE_FOLDER=$1
REPOSITORY_NAME=$2
WORKING_DIR=$3

gum_log_info "$(gum_blue " ") $(git_strong_gray_light "$MODULE_FOLDER")"
gum_log_info "$(gum_blue " ") $(git_strong_gray_light "$REPOSITORY_NAME")"
gum_log_info "$(gum_blue " ") $(git_strong_gray_light "$WORKING_DIR")"
if [[ ! -d "$WORKING_DIR/$REPOSITORY_NAME/$MODULE_FOLDER/i18n" ]]; then
    gum_log_debug "$(gum_blue " ") $(git_strong_gray_light "Creating translations directory")"
    mkdir -p "$WORKING_DIR/$REPOSITORY_NAME/$MODULE_FOLDER/i18n"
fi

if mv -f "$WORKING_DIR/$FILE_NAME" "$WORKING_DIR/$REPOSITORY_NAME/$MODULE_FOLDER/i18n/$FILE_NAME"; then
    gum_log_info "$(gum_blue " ") $(git_strong_gray_light "The translation was copied correctly to $MODULE_FOLDER")"
else
    gum_log_error "$(gum_blue " ") $(git_strong_gray_light "There was an error while copying the translation")"
fi

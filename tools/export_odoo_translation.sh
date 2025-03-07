#!/bin/bash

FILE_NAME="es_MX.po"
MODULE_PATH_FOLDER=$1
DOCKER_CONTAINER_PATH=$2
if [[ ! -d "$MODULE_PATH_FOLDER/i18n" ]]; then
    mkdir -p "$MODULE_PATH_FOLDER/i18n"
fi

if mv -f "$DOCKER_CONTAINER_PATH/$FILE_NAME" "$MODULE_PATH_FOLDER/i18n/$FILE_NAME"; then
    echo "The translation was copied correctly to $MODULE_PATH_FOLDER"
else
    echo "There was an error while copying the translation"
fi

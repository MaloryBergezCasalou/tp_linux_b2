#!/bin/bash

# malorybergezcsalou
# 07/10/2020
# Test pour le backup du script

backup_time="$(date +%Y%m%d_%H%M)"

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

backup_dir="/opt/backup"

backup_path="${backup_dir}/${backup_name}.tar.gz"

backup_useruid="1002"
max_backup_number=7

# On vérifie que l'user qui execute le script est bien backup
if [[ $UID -ne ${backup_useruid} ]]
then
    echo "Ce script doit être éxecuté avec l'utilisateur backup" >&2
    exit 1
fi

# On vérifie que le dossier qu'on doit backup existe
if [[ ! -d "${saved_folder_path}" ]]
then
    echo "Ce dossier n'existe pas !" >&2
    exit 1
fi

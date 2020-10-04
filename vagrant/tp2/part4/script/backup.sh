#!/bin/bash
# malorybergezcasalou
# 4 octibre 2020
# Script de backup avec une limite de 7 backups

target_dir="${1}"
target_path="$(echo "${target_dir%/}" | awk -F "/" 'NF>1{print $NF}')"

date="$(date +%Y%m%d_%H%M%S)"
backup_name="${target_path}_${date}"
backup_dir="/opt/backup"
backup_path="${backup_dir}/${target_path}/${backup_name}.tar.gz"

backup_useruid="1003"
max_backup_number=7

if [[ $UID -ne ${backup_useruid} ]]
then
    echo "Ce script doit être éxecuté avec l'utilisateur backup" >&2
    exit 1
fi

if [[ ! -d "${target_dir}" ]]
then
    echo "Le dossier spécifié n'existe pas !" >&2
    exit 1
fi

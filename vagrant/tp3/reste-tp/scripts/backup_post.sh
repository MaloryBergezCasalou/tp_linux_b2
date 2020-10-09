#!/bin/bash

# malorybergezcasalou
# 07/10/2020
# Backup post script

backup_time="$(date +%Y%m%d_%H%M)"

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

backup_dir="/opt/backup"

backup_path="${backup_dir}/${backup_name}.tar.gz"

backup_useruid="1003"
max_backup_number=7

# Fonction qui supprime la backup la plus vielle si on a plus de 7 backup
delete_outdated_backup ()
{
    if [[ $(ls "${backup_dir}/${saved_folder_path}" | wc -l) -gt max_backup_number ]]
    then
        oldest_file=$(ls -t "${backup_dir}/${saved_folder_path}" | tail -1)
        rm -rf "${backup_dir}/${saved_folder_path}/${oldest_file}"
    fi
}

delete_outdated_backup

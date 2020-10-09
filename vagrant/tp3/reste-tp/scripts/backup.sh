
#!/bin/bash

# malorybergezcasalou
# 07/10/2020
# Backup script

backup_time="$(date +%Y%m%d_%H%M)"

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

backup_dir="/opt/backup"

backup_path="${backup_dir}/${backup_name}.tar.gz"

backup_useruid="1003"
max_backup_number=7

# Fonction qui crée la backup
backup_folder ()
{
    if [[ ! -d "${backup_dir}/${saved_folder_path}" ]]
    then
        mkdir "${backup_dir}/${saved_folder_path}"
    fi
    
    tar -czvf \
    ${backup_path} \
    ${target_dir} \
    1> /dev/null \
    2> /dev/null
    
    if [[ $(echo $?) -ne 0 ]]
    then
        echo "Une erreur est survenue lors de la compréssion" >&2
        exit 1
    else
        echo "La compréssion à réussi dans ${backup_dir}/${saved_folder_path}" >&1
    fi
}

backup_folder

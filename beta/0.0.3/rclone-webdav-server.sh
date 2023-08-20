#!/bin/bash

if [ -z "$1" ]; then
  username="username"
else
  username="$1"
fi

if [ -z "$2" ]; then
  password="password"
else
  password="$2"
fi
if [ -z "$3" ]; then
  bwlimit="0"
else
  bwlimit="$3"
fi

data_folde=$"/data"
config_folder=$"/data/config"
Log_folder=$"/data/Log"
if [ ! -d "$data_folde" ]; then
    mkdir -p "$data_folde"
fi
if [ ! -d "$Log_folder" ]; then
    mkdir -p "$Log_folder"
fi
if [ ! -d "$config_folder" ]; then
    mkdir -p "$config_folder"
fi

config_folder=$"/data/config"
rclone_conf_source=$"/root/.config/rclone/rclone.conf"
rclone_conf_destination=$"/data/config/rclone.conf"
echo "$config_folder \r\n $rclone_conf_source \r\n $rclone_conf_destination"
if [ ! -f $rclone_conf_destination ]; then
  if [ ! -f $rclone_conf_source ]; then
    echo "rclone.conf가 없습니다. 'rclone config'를 실행하여 구성하십시오!"
    /bin/bash
    else 
    echo ""$rclone_conf_source 에서 $rclone_conf_destination 복사"

    cp -f "$rclone_conf_source $rclone_conf_destination" 
  fi  
  echo ""$rclone_conf_destination에서 $rclone_conf_source 복사"
cp -f "$rclone_conf_destination $rclone_conf_source"
else
    echo ""$rclone_conf_source 에서 $rclone_conf_destination 복사"

cp -f "$rclone_conf_source $rclone_conf_destination"  
fi

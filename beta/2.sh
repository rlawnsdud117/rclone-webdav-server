#!/bin/bash
# Scripts related to automatic updates
curl -sL "https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/beta/2.sh" -o "./webdav-server.sh"
chmod +x /webdav-server.sh


# Set default values for parameters if not provided
username="${username:-username}"  
password="${password:-password}"  
bwlimit="${bwlimit:-$bwlimit}"          
tpslimit="${tpslimit:-$tpslimit}"          
readonly="${readonly:-$readonly}"          
cachemode="${cachemode:-$cachemode}"  
debugmode="${debugmode:-$debugmode}"        
webgui="${webgui:-$webgui}"        

# echo "Username: $username"
#echo "Password: $password"
#echo "Bandwidth Limit: $bwlimit"
#echo "TPS Limit: $tpslimit"
#echo "Readonly: $readonly"
#echo "Cache Mode: $cachemode"
#echo "Debug Mode: $debugmode"

# Set flags based on provided parameters
bwlimit_flag=""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag="--bwlimit $bwlimit"
fi

readonly_flag=""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag="--read-only"
fi

debug_flag=""
if [[ "${debugmode,,}" != "off" && "$debugmode" != "0" && -n "$debugmode" ]]; then
  debug_flag="--log-file /data/log/log.log"
fi

Log_folder="/data/Log"
etc_webdav_folder="/etc/webdav"

if [ ! -d "$Log_folder" ]; then
    mkdir -p "$Log_folder"
fi

if [ ! -d "$etc_webdav_folder" ]; then
    mkdir -p "$etc_webdav_folder"
fi

cache_flag=""
if [[ "${cachemode,,}" == "on" ]]; then
    mkdir -p "/data/cache"
    cache_flag="--cache-dir /data/cache"
fi

config_folder="/data/config"
config_file="/data/config/rclone.conf"

# Check if rclone.conf exists and copy it if not
if [ ! -f $config_file ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf does not exist. Please run 'rclone config' to configure it!" 
    /bin/bash
  fi
  mkdir -p "$config_folder"
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi


# Process the section name
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9 _-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")

if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
echo "The first line in the rclone.conf file does not contain a valid section name."
/bin/bash
fi

# Remove brackets and replace spaces with underscores
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/' | tr ' ' '_')

# Update section name in the file
sed -i "1s/.*/[$section_name]/" "$config_file"


#-----------------------------------------------------------------

# Generate htpasswd file
htpasswd_file="/etc/webdav/htpasswd"
echo "$username:$(openssl passwd -apr1 $password)" > "$htpasswd_file"


if [[ "${webgui,,}" != "off" && "$webgui" != "0" && -n "$webgui" ]]; then
  rclone rcd --rc-web-gui --rc-addr 0.0.0.0:808 --rc-htpasswd $htpasswd_file

fi


# rclone-webdav-server

This script allows you to use various cloud services through WebDAV Apache2 using rclone.

# How to use
1. Download this script.
2. Before running the script, install the necessary packages using the following command:
``` apt-get update && apt-get install -y curl && apt-get install -y unzip && curl https://rclone.org/install.sh | bash && apt-get install -y apache2 && rclone .
```
# 3
4. Run rclone config to configure it.
- rclone config
6. Download the script using curl.
- curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/webdav-server.sh
7. Give the sh file permission first
- chmod +x /webdav-server.sh
8.  Run the script.
- ./webdav-server.sh username password 30m
7. Open http://localhost:80/ in your web browser.

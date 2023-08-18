# rclone-webdav-server

This script allows you to utilize various cloud services through WebDAV on Apache2 using rclone.

# How to use
1. Download this script.
2. Before running the script, install the necessary packages using the following command:
```
apt-get update && apt-get install -y curl && apt-get install -y unzip && curl https://rclone.org/install.sh | bash && apt-get install -y apache2 && rclone .
```
3. Configure rclone by running the command:
```
rclone config
```
4. Download the script using curl:
```
curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/webdav-server.sh
```
5. Provide execute permission to the sh file:
```
chmod +x /webdav-server.sh
```
6.  Run the script.
```
./webdav-server.sh username password 30m
```
7. Open http://localhost:80/ in your web browser.

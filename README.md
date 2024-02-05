# rclone-webdav-server

This script allows you to utilize various cloud services through WebDAV on Apache2 using rclone.

# How to use
1. Download this script.
2. Before running the script, install the necessary packages using the following command:
```
apt-get update && apt-get install -y curl unzip apache2 && curl https://rclone.org/install.sh | bash
```
3. Configure rclone by running the command:
```
rclone config
```
4. Download the script using curl:
```
curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/rclone-webdav-server.sh
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

## LICENSE
```
Copyright (C) 2023 JUNYOUNGKIM (juni65423@gmail.com)
 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
```

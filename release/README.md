# Update History for the Rclone WebDAV Server Script
Unless serious bugs/errors arise in my script, it is highly likely that version top will be the final release.
## Version 0.0.1 has been released.
1. I have added a log file.
2. The configuration location has been changed.
## Version 0.0.2 has been released.
1. Instead of moving the rclone.conf file, I've added a script command to copy the file from /data/config/rclone.conf.
## Version 0.0.3 has been released.
1. Reading mode has been added.
## Version 0.0.4 has been released.
1. I've added a feature (cachefolder) to enable or disable the upload and download cache folder.
2. The issue where the file transfer rate limit (tpslimit) wasn't functioning has been resolved.
3. The problem where the speed limit (bwlimit) wasn't working when it was off, empty, or set to 0 has been fixed.
## Version 0.0.5 has been released.
1. I removed apache2 from the Dockerfile script because I don't use it in rclone. Instead, I'm utilizing the built-in web server within rclone, and I'm creating user accounts using openssl.
## Version 0.0.6 has been released.
1. You've implemented a feature to open the "rclone.conf" file and replace all spaces in the section names with underscores (_).
## Version 0.0.7 has been released.
1. The script now includes an automatic update feature.
2. The variable "cachefolder" is renamed to "cachemode" in the cache mode.
3. I've made it possible for users to manually disable the debugging mode (debugmode).

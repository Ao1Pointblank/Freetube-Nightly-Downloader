# Freetube-Nightly-Downloader
Bash script to download the latest nightly build of the privacy-friendly Youtube client, FreeTube.
  
  
  
**Intended Use Case:**  
Run this script periodically with cron or anacron to automatically save the latest nightly build of FreeTube.
A separate cron/anacron command can be used to also automatically install and remove the downloaded packages,
but that is outside the scope of this project at least for now, since it may introduce security risks if I tell
people to start using sudo commands in automation.
  
  
  
**Requirements:**  
- `jq, curl, unzip`
- a Github token to access the repo:
  please visit https://github.com/settings/tokens and create a new token with the Repo scope!
  You will have to paste this private token into the script, replacing `YOUR_TOKEN` with the actual token.
  
  
  
**Options:**

`--architecture <arch>`  Filter artifacts by architecture (e.g., amd64, arm64, armv7l, mac)

`--format <format>`      Filter artifacts by format (e.g., deb, rpm, appimage, 7z, apk, pacman, dmg, exe)
                       (Please note that .zip options are not supported due to a limitation of the script and GitHub not showing .zip file endings. Searching for 7z is recommended instead.)
                         
`--auto-download`        Automatically download the artifact if only one result is found. It will not allow the same version to be downloaded again.

`--output <directory>`   Specify the directory where the downloaded file will be saved.

`--help`                 Display this help information  
  
  
  
**Optional Integration with Cron/Anacron: (do all this yourself)**  
I didn't test very much with a user anacrontab, I just went straight to the root anacrontab. This may pose security risks, since it is installing software automatically from a remote source. I encourage users to research ways to add these commands to a user-specific cron.  
Use at your own risk:  

```
/etc/anacrontab: configuration file for anacron
SHELL=/bin/sh
HOME=/root
LOGNAME=root

#my commands
2 3 pointblank /home/pointblank/.local/bin/freetube_nightly_download.sh --architecture amd64 --format deb --auto-download --output /tmp
2 4 pointblank sudo dpkg -i /tmp/freetube_*_amd64.deb
```  
In the above lines, the first line for each anacrontab command is the frequency of recurrence, in days. The second number is an additional delay in minutes before running the commands. "pointblank" is my username but I'm pretty sure this can be replaced with any single word to help you identify the process being run if it has an error.
 


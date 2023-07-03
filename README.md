# Freetube-Nightly-Downloader
Bash script to download the latest nightly build of the privacy-friendly Youtube client, FreeTube.

Made with the help of ChatGPT.

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


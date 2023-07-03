#!/bin/bash

#v1.0.1 by Ao1Pointblank and ChatGPT

#dependencies: jq, curl, unzip

###please visit https://github.com/settings/tokens and create a new "classic" token with the Repo scope!
TOKEN="YOUR_TOKEN"

# Color codes for highlighting
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

# GitHub repository information
REPO_OWNER="FreeTubeApp"
REPO_NAME="FreeTube"
WORKFLOW_FILE=".github/workflows/build.yml"
CACHE_FILE="$HOME/.cache/freetube_last_downloaded.txt"

# Function to display usage information
show_help() {
  echo "Usage: ./freetube_nightly_download.sh [OPTIONS]"
  echo "Download FreeTube nightly builds from GitHub."
  echo "Dependencies: jq, curl, unzip"
  echo "You will also need a Github account token with the Repo scope permission. Please visit https://github.com/settings/tokens"
  echo
  echo "Options:"
  echo "  --architecture <arch>  Filter artifacts by architecture (e.g., amd64, arm64, armv7l, mac)"
  echo "  --format <format>      Filter artifacts by format (e.g., deb, rpm, appimage, 7z, apk, pacman, dmg, exe)"
  echo "                         Please note that .zip options are not supported due to a limitation of the script and GitHub not showing .zip file endings. Searching for 7z is recommended instead."
  echo "  --auto-download        Automatically download the artifact if only one result is found. It will not allow the same version to be downloaded again unless --force is used."
  echo "  --output <directory>   Specify the directory where the downloaded file will be saved."
  echo "  --force                Used in conjunction with --auto-download to force download the artifact, even if the same version has already been downloaded."
  echo "  --help                 Display this help information"
}

# Check for --help command
if [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --architecture)
      architecture="$2"
      shift
      ;;
    --format)
      format="$2"
      shift
      ;;
    --auto-download)
      auto_download="true"
      ;;
    --output)
      output_directory="$2"
      shift
      ;;
    --force)
      force="true"
      ;;
    *)
      echo "Unknown option: $key"
      show_help
      exit 1
      ;;
  esac
  shift
done

# Set the output directory to the current working directory if not specified
if [[ -z "$output_directory" ]]; then
  output_directory=$(pwd)
fi

# Fetch the workflow runs for the workflow file
api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$(basename $WORKFLOW_FILE)/runs"
response=$(curl -s -H "Authorization: token $TOKEN" "$api_url")

# Extract the latest run ID from the response using jq
latest_run_id=$(echo "$response" | jq -r '.workflow_runs[0].id')

echo "Latest Run ID: $latest_run_id"

# Fetch the artifacts for the latest run
artifacts_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$latest_run_id/artifacts"
artifacts_response=$(curl -s -H "Authorization: token $TOKEN" "$artifacts_url")

# Extract the artifact names from the response using jq
artifact_names=$(echo "$artifacts_response" | jq -r '.artifacts[].name')

# Filter artifacts based on provided options
if [[ -n "$format" ]]; then
  artifact_names=$(echo "$artifact_names" | grep -i "$format")
fi

if [[ -n "$architecture" ]]; then
  artifact_names=$(echo "$artifact_names" | grep -i "$architecture")
fi

# Check the number of resulting artifacts
num_artifacts=$(echo "$artifact_names" | wc -l)

if [[ $num_artifacts -eq 1 && "$auto_download" == "true" ]]; then
  # Check if the last downloaded file matches the selected artifact (allowing slight name differences)
  last_downloaded_file=$(cat "$CACHE_FILE")
  selected_file=$(echo "$artifact_names" | sed -n 1p)
  if [[ -n "$last_downloaded_file" && "$last_downloaded_file" == *"$selected_file"* && "$force" != "true" ]]; then
    echo "Artifact already downloaded. Skipping auto-download."
  else
    # Download the artifact
    artifact_id=$(echo "$artifacts_response" | jq -r --arg name "$selected_file" '.artifacts[] | select(.name == $name) | .id')
    download_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/artifacts/$artifact_id/zip"
    echo -e "Downloading artifact: ${GREEN}$selected_file${RESET}"
    curl -s -H "Authorization: token $TOKEN" -o "${output_directory}/${selected_file}.zip" -L "$download_url"
    echo "Artifact downloaded successfully."

    # Unzip the artifact to the current directory
    unzip -q "${output_directory}/${selected_file}.zip" -d "$output_directory"
    echo "Artifact unzipped successfully."

    # Clean up the downloaded zip file
    rm "${output_directory}/${selected_file}.zip"
    echo "Zip file removed."

    # Update the cache file with the last downloaded file
    echo "$selected_file" > "$CACHE_FILE"
  fi

  exit 0
fi

# Print the filtered artifacts with colors
echo -e "Filtered Artifacts (Format: ${RED}$format${RESET}, Architecture: ${RED}$architecture${RESET}):"
echo -e "${GREEN}$artifact_names${RESET}"

# Prompt the user to choose an artifact
read -p "Enter the name of the artifact you want to download: " artifact_name

# Download the selected artifact
artifact_id=$(echo "$artifacts_response" | jq -r --arg name "$artifact_name" '.artifacts[] | select(.name == $name) | .id')
download_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/artifacts/$artifact_id/zip"
curl -s -H "Authorization: token $TOKEN" -o "${output_directory}/${artifact_name}.zip" -L "$download_url"
echo "Artifact downloaded successfully."

# Unzip the artifact to the current directory
unzip -q "${output_directory}/${artifact_name}.zip" -d "$output_directory"
echo "Artifact unzipped successfully."

# Clean up the downloaded zip file
rm "${output_directory}/${artifact_name}.zip"
echo "Zip file removed."

# Update the cache file with the last downloaded file
echo "$artifact_name" > "$CACHE_FILE"

exit 0

#!/usr/bin/env bash

###############################################################################################################################
# Description: This script installs the Scheduler program on any linux distribution, including dependencies and required files.
# Dependencies: It is compatible with package managers apt, dnf, pacman, and zypper.
# Source: https://github.com/amateur-hacker/scheduler.git
# Usage: ./install.sh
# Author: Amateur Hacker
###############################################################################################################################

# Exit if any command fails or any undefined variable is used
set -euo pipefail

# Clear the screen before playing the mp3.
clear

# Play an audio message to inform the user that the program is being installed
nohup ffplay -hide_banner -nodisp -autoexit -nostats -loglevel 0 ./downloads/scheduler-voices/charles/inststart.wav > /dev/null 2>&1 &

python3 - <<END
import time
message = "Sir, Your scheduler program is going to be installed in your system."
for char in message:
    print(char, end="", flush=True)
    time.sleep(0.056)
END

# Wait for the audio message to finish and then clear the screen
sleep 0.5s
clear

# Display the program logo to make it more attractive
echo ""
echo -e "\e[1m███████╗ ██████╗██╗  ██╗███████╗██████╗ ██╗   ██╗██╗     ███████╗██████╗\e[0m"
echo -e "\e[1m██╔════╝██╔════╝██║  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔════╝██╔══██╗\e[0m"
echo -e "\e[1m███████╗██║     ███████║█████╗  ██║  ██║██║   ██║██║     █████╗  ██████╔╝\e[0m"
echo -e "\e[1m╚════██║██║     ██╔══██║██╔══╝  ██║  ██║██║   ██║██║     ██╔══╝  ██╔══██╗\e[0m"
echo -e "\e[1m███████║╚██████╗██║  ██║███████╗██████╔╝╚██████╔╝███████╗███████╗██║  ██║\e[0m"
echo -e "\e[1m╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝\e[0m"
echo ""


# Define the list of dependencies
dependencies=("mpv" "python3" "rofi")

# Check which package manager is installed
if hash apt 2>/dev/null; then
  sudo apt-get update
  install_command="sudo apt-get install -y"
  libnotify_package="libnotify-bin"

elif hash dnf 2>/dev/null; then
  sudo dnf update
  install_command="sudo dnf install -y"
  libnotify_package="libnotify"

elif hash pacman 2>/dev/null; then
  sudo pacman -Sy
  install_command="sudo pacman -S --noconfirm"
  libnotify_package="libnotify"

elif hash zypper 2>/dev/null; then
  sudo zypper update
  install_command="sudo zypper install"
  libnotify_package="libnotify"

else
  echo "Could not find a supported package manager."
  exit 1
fi

# Check if dependencies are already installed
missing_deps=()
for dep in "${dependencies[@]}"; do
  if ! hash "$dep" 2>/dev/null; then
    missing_deps+=("$dep")
  fi
  if ! hash notify-send 2>/dev/null; then
    missing_deps+=("$libnotify_package")
  fi
done

if [[ ${#missing_deps[@]} -eq 0 ]]; then
  echo "Dependencies (${dependencies[*]}) are already installed."
else
  # Prompt user for sudo password up front
  sudo -v

  # Install missing dependencies
  echo "##########################################################"
  echo "## Confirm to install ${missing_deps[*]} ##"
  echo "##########################################################"
  echo ""
  eval "$install_command ${missing_deps[*]}"
fi

# Copy files to appropriate directories
echo ""
echo "#########################################################################################"
echo "## Started copying all the required folder/files for scheduler program to your system. ##"
echo "#########################################################################################"
echo ""

sleep 1s

# Touch two important files in home directory from this program's purpose:

# In ($HOME/schedule.txt-> default location), your schedule will be saved automatically by the program, or you can manually write your schedule by opening the file using your preferred text editor.
if [[ ! -f "$HOME/schedule.txt" ]]; then
  touch "$HOME/schedule.txt"
fi

# In ($HOME/daily-schedule.txt-> default location) your daily schedule completion status will be saved.
if [[ ! -f "$HOME/schedule-status.txt" ]]; then
  touch "$HOME/schedule-status.txt"
fi

# First touching the .xprofile file if not exist then copying echo syntax to the appropriate file.
if [[ ! -f "$HOME/.xprofile" ]]; then
  touch "$HOME/.xprofile"
fi

if ! grep -q "$HOME/.local/bin/check-schedule-bg" "$HOME/.xprofile"; then
  echo "$HOME/.local/bin/check-schedule-bg" >> "$HOME/.xprofile"
fi

# Copy default configuration file for the scheduler program to the appropriate directory
rsync -arvP ./.config/scheduler "$HOME/.config/"

# Copy notification icon to the appropriate directory
sudo rsync -arvP ./icons/* "/usr/share/icons/"

# Copy CLI version of the scheduler program to the appropriate directory
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi
rsync -arvP ./script/* "$HOME/.local/bin/"

if ! ps -ef | grep -v grep | grep -q "check-schedule"; then
  echo "Starting the background process to check the schedule for the first time, it will be automatically handled after that."
  bash "$HOME/.local/bin/check-schedule-bg"
else
  :
fi

# Copy MP3 files to the appropriate directory for the scheduler program
if [ ! -d "$HOME/Downloads" ]; then
    mkdir -p "$HOME/Downloads"
fi
rsync -arvP ./downloads/scheduler-voices "$HOME/Downloads/"

# Copy manual page for the scheduler program to the appropriate directory
sudo rsync -arvP ./man/sch.1.gz "/usr/share/man/man1/"

# Copy rofi configuration files to the appropriate directory
if [ ! -d "$HOME/.config/rofi" ]; then
    mkdir -p "$HOME/.config/rofi"
    rsync -arvP ./.config/rofi/config.rasi "$HOME/.config/rofi/"
elif [ -d "$HOME/.config/rofi.bak" ]; then
    :
else
    mv "$HOME/.config/rofi" "$HOME/.config/rofi.bak"
    mkdir -p "$HOME/.config/rofi"
    rsync -arvP ./.config/rofi/config.rasi "$HOME/.config/rofi/"
fi

if [ ! -d "$HOME/.local/share/rofi/themes" ]; then
    mkdir -p "$HOME/.local/share/rofi/themes"
    rsync -arvP ./.config/rofi/catppuccin-mocha.rasi "$HOME/.local/share/rofi/themes/"
elif [ -d "$HOME/.local/share/rofi.bak" ]; then
    :
else
    mv "$HOME/.local/share/rofi" "$HOME/.local/share/rofi.bak"
    mkdir -p "$HOME/.local/share/rofi/themes"
    rsync -arvP ./.config/rofi/catppuccin-mocha.rasi "$HOME/.local/share/rofi/themes/"
fi

if [[ ! -d "$HOME/.cache/scheduler-updates" ]]; then
  echo "Adding update.sh and update-apply.sh file in .cache/scheduler-updates folder for udpate purposes"
  mkdir -p "$HOME/.cache/scheduler-updates"
  rsync -arvP ./update.sh "$HOME/.cache/scheduler-updates"
  rsync -arvP ./update-apply.sh "$HOME/.cache/scheduler-updates"
else
  echo "Adding update.sh and update-apply.sh file in .cache/scheduler-updates folder for udpate purposes"
  rsync -arvP ./update.sh "$HOME/.cache/scheduler-updates"
  rsync -arvP ./update-apply.sh "$HOME/.cache/scheduler-updates"
fi

echo ""
echo "##########################################################################################"
echo "## Finished copying all the required files/folder for scheduler program to your system. ##"
echo "##########################################################################################"
echo ""

# Play an audio message to inform the user that the program has been successfuly installed in their system.
nohup ffplay -hide_banner -nodisp -autoexit -nostats -loglevel 0 ./downloads/scheduler-voices/charles/instfinish.wav > /dev/null 2>&1 &

python3 - <<END
import time
message = "Sir, I am pleased to inform you that your scheduler program has been successfully installed in your system without any errors. Now you can enjoy the convenience of scheduler."
for char in message:
    print(char, end="", flush=True)
    time.sleep(0.05)
END

sleep 1s

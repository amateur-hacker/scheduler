#!/usr/bin/env bash

###############################################################################################################################
# Description: This script apply the updates in the Scheduler program
# Source: https://gitlab.com/amateur_hacker/scheduler.git
# Author: Amateur Hacker
###############################################################################################################################

# Check if the temp_update.sh script does not exist in /tmp folder
if [[ ! -f /tmp/temp_update.sh ]]; then
  # Download the latest version of the update.sh script into /tmp folder
  cd /tmp && wget -O temp_update.sh https://raw.githubusercontent.com/amateur-hacker/scheduler/master/update.sh &>/dev/null && chmod +x temp_update.sh

# Check if the temp_update.sh script exist
else
  # Remove the existing temp_update.sh script from /tmp folder
  rm -rf /tmp/temp_update.sh
  # Download the latest version of the update.sh script into /tmp folder
  cd /tmp && wget -O temp_update.sh https://raw.githubusercontent.com/amateur-hacker/scheduler/master/update.sh &>/dev/null && chmod +x temp_update.sh
fi

# Check if there are any differences between the temp_update.sh script and the one stored in the cache folder
if diff /tmp/temp_update.sh "$HOME/.cache/scheduler-updates/update.sh" &>/dev/null ; then 
  echo "Scheduler program is already up-to-date." 
  sleep 2s
else 
  # Clone the scheduler repository into /tmp folder and run the update.sh script
  cd /tmp && git clone https://github.com/amateur-hacker/scheduler.git &>/dev/null
  cd /tmp/scheduler/ && ./update.sh

  # Update the latest update.sh file in the ~/.cache/scheduler-updates folder
  cd /tmp/scheduler && rsync -ravP ./update.sh "$HOME/.cache/scheduler-updates/update.sh"
fi

# Remove the temp_update.sh script
rm -rf /tmp/temp_update.sh

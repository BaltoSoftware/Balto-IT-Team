#!/bin/zsh

# URL to raw file on GitHub
baseURL="https://raw.githubusercontent.com/BaltoSoftware/Balto-IT-Team/main/macOS/Nudge/LaunchAgents"
# Name of plist in the repository
fileName="Balto-NudgeLaunchAgent-1.0.plist"
# If you change your agent file name, update the following line
launch_agent_plist_name='com.github.macadmins.Nudge.plist'
# Base paths
launch_agent_base_path='Library/LaunchAgents/'

curl -LJ ${baseURL}/${fileName} -o "$3/${launch_agent_base_path}${launch_agent_plist_name}"


# Fail the install if the admin forgets to change their paths and they don't exist.
if [ ! -e "$3/${launch_agent_base_path}${launch_agent_plist_name}" ]; then
  echo "LaunchAgent missing, exiting"
  exit 1
fi

  # Current console user information
  console_user=$(/usr/bin/stat -f "%Su" /dev/console)
  console_user_uid=$(/usr/bin/id -u "$console_user")

  # Only enable the LaunchAgent if there is a user logged in, otherwise rely on built in LaunchAgent behavior
  if [[ -z "$console_user" ]]; then
    echo "Did not detect user"
  elif [[ "$console_user" == "loginwindow" ]]; then
    echo "Detected Loginwindow Environment"
  elif [[ "$console_user" == "_mbsetupuser" ]]; then
    echo "Detect SetupAssistant Environment"
  elif [[ "$console_user" == "root" ]]; then
    echo "Detect root as currently logged-in user"
  else
    # Unload the agent so it can be triggered on re-install
    /bin/launchctl asuser "${console_user_uid}" /bin/launchctl unload -w "$3/${launch_agent_base_path}${launch_agent_plist_name}"
    # Kill Nudge just in case (say someone manually opens it and not launched via launchagent
    /usr/bin/killall Nudge
    # Load the launch agent
    /bin/launchctl asuser "${console_user_uid}" /bin/launchctl load -w "$3/${launch_agent_base_path}${launch_agent_plist_name}"
  fi
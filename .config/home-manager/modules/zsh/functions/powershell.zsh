# export WINGET="/mnt/c/Users/mfari/AppData/Local/Microsoft/WindowsApps/winget.exe"
# alias pwsh="'/mnt/c/Program Files/PowerShell/7/pwsh.exe'"

pwsh_run() {
  local powershell_path='/mnt/c/Program Files/PowerShell/7/pwsh.exe'
  "$powershell_path" -Command "& { $1 }" "${@:2}"
}

# -- Commands --
# winget
cmd_winget() {
  # local winget_path='(Get-AppxPackage -Name Microsoft.DesktopAppInstaller).InstallLocation + "\\winget.exe"'
  # local winget_path='C:\\Users\\mfari\\AppData\\Local\\Microsoft\\WindowsApps\\winget.exe'
  # local winget_path="(Get-Command winget).Source"
  # pwsh_run "$winget_path" "$@"
  pwsh_run "winget $*"
}

# task
cmd_task() {
  pwsh_run "New_ScheduleTask $@"
}

# add user to group
cmd_group() {
  local user="$1"
  local group="$2"
  pwsh_run "Add-LocalGroupMember -Group '$group' -Member '$user'"
}

# elevated Powershell (as Administrator)
cmd_elevate() {
  pwsh_run "Start-Process powershell -Verb RunAs -ArgumentList '-Command', '$*'"
}

# disable UAC
cmd_disable_uac() {
  pwsh_run "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System -Name ConsentPromptBehaviorAdmin -Value 0"
}

# enable UAC
cmd_enable_uac() {
  pwsh_run "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System -Name ConsentPromptBehaviorAdmin -Value 5"
}

# other command
cmd_exec() {
  pwsh_run "$@"
}

# help
cmd_help() {
  echo "Windows Powershell Commands from WSL"
  echo "Usage: pwsh [command] [options]"
  echo ""
  echo "Commands:"
  echo "  winget [args]               - Run winget package manager"
  echo "  task [args]                 - Create scheduled tasks"
  echo "  group [user] [group]        - Add user to a group"
  echo "  elevate [command]           - Run a Powershell command as Administrator"
  echo "  disable_uac                 - Disable User Account Control prompts"
  echo "  enable_uac                  - Enable User Account Control prompts"
  echo "  exec [command]              - Execute any Powershell command"
  echo "  help                        - Show this help"
  echo ""
  echo "Examples:"
  echo "  pwsh winget search firefox"
  echo "  pwsh task -TaskName 'MyTask' -Action (New-ScheduledTaskAction -Execute 'notepad.exe')"
  echo "  pwsh group username Administrators"
  echo "  pwsh elevate 'Install-WindowsFeature -Name Web-Server'"
  echo "  pwsh disable_uac      # Disables 'Run as administrator' prompts"
  echo "  pwsh enable_uac       # Restores default UAC behavior"
  echo "  pwsh exec 'Get-Process | Sort-Object CPU -Descending | Select-Object -First 5'"
}

main () {
  # Default to help if no command 
  local cmd=${1:-help}
  shift || true

  # Convert command to lowercase for case-insensitivity
  cmd=$(echo "$cmd" | tr '[:upper:]' '[:lower:]')

  # Find and execute the appropriate function
  if type "cmd_$cmd" &>/dev/null; then
    "cmd_$cmd" "$@"
  else
    echo "Unknown command: $cmd"
    cmd_help
    return 1
  fi
}

# Create the main wrapper function
pwsh() {
  main "$@"
}

# Optional: Run the main function if script is executed directly
# if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
#   main "$@"
# fi

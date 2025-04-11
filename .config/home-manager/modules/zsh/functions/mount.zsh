mount_drive() {
  # echo "mount started" >> /home/mfari/boot_log.txt
  # Task name
  task_name="mount-wsl-disk"

  # Windows system path
  windows_sys_path="/mnt/c/Windows/System32"

  # Command to execute task
  task_command="schtasks.exe"

  # Timeout and interval in seconds
  timeout=10
  interval=1

  # Drive to check and mount
  target_drive="/dev/sdd1"

  # echo "Executing task"
  # Execute the task
  "${windows_sys_path}/${task_command}" /run /tn "$task_name"

  # Initialize elapsed time counter
  elapsed=0

  # Wait for the target drive to be ready
  while [ ! -e $target_drive ]; do
    if [ $elapsed -ge $timeout ]; then
      echo "Timed out waiting for $target_drive to be ready."
      exit 1
    fi

    echo "Waiting for $target_drive to be ready..."
    sleep $interval
    elapsed=$((elapsed + interval))
  done
}

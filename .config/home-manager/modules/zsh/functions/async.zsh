check_lazysql_config() {
  local CONFIG_PATH="$HOME/.config/lazysql/config.toml"

  if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "Warning: LazySQL config not found at $CONFIG_PATH"
  fi
}

mount_drive_async() {
  if command -v mount_drive >/dev/null && ! mountpoint -q "/mnt/wsl/PHYSICALDRIVE0p1"; then
    mount_drive
  fi
}

setup_wayland_async() {
  SOURCE_PATH="/mnt/wslg/runtime-dir/wayland-0"
  TARGET_PATH="/run/user/$UID/wayland-0"

  if [ -e "$SOURCE_PATH" ] && [ ! -e "$TARGET_PATH" ]; then
      mkdir -p "/run/user/$UID"
      ln -s "$SOURCE_PATH" "$TARGET_PATH"
      echo "WSLg Wayland socket linked for Nix/Neovim."
  fi
}

check_nixbin_async() {
  if command -v check_nixbin >/dev/null; then
    check_nixbin
  fi
}

async_start_jobs() {
  async_start_worker my_worker -n

  async_job my_worker mount_drive_async
  async_job my_worker setup_wayland_async

  async_job my_worker check_lazysql_config

  async_job my_worker check_nixbin_async
}

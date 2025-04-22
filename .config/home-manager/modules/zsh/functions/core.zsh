clear() {
    /usr/bin/clear
    printf "\n%.0s" {1..100}
}

config() {
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

dotfiles_update() {
    config add -u && \
    config commit -m "Update $(date +"%Y-%m-%d %H:%M") \
        $(uname -s)/$(uname -m)-$(hostname -s)" && config push -u origin main
}

dotfiles_init() {
    git --no-replace-objects clone --bare --depth 1 \
        https://github.com/hangtaip/dotfiles.git $HOME/.dotfiles;
    config config --local status.showUntrackedFiles no;
    config checkout -f
}

dvd() {
    echo "use flake \"github:hangtaip/dev-templates?dir=$1\"" >> .envrc
    direnv allow
}

dvt() {
    nix flake init -t "github:hangtaip/dev-templates#$1"
    direnv allow
}

# TODO:
# if file exist, if reinitiate, do nothing
# if file exist, different type, merge
# remove duplicate
gig() {
    if [[ -z "$1" ]]; then
        echo "Usage: gig <type> (e.g., node, python, etc.)" >&2
        return 1
    fi

    local template=$HOME/.config/git/templates/gitignore/gitignore_$1 
    if [[ -f "$template" ]]; then
        cp "$template" ./.gitignore
        echo "Created .gitignore for $1"
    else
        echo "Error: Template '$template' not found!" >&2
        return 1
    fi
}

gpc() {
    local TIMEOUT=$(gopass config cliptimeout 2>/dev/null)

    if [[ ! "$TIMEOUT" =~ ^[0-9]+$ ]]; then
        TIMEOUT=15
    fi

    gopass show "$1" | clip.exe
    printf "\nPassword copied to windows clipboard (clearing in %s seconds)...\n" "$TIMEOUT"

    (
        sleep $TIMEOUT
        echo -n "" | clip.exe
        noty
    ) &>/dev/null &!
}

noty() {
    powershell.exe -Command "
        Add-Type -AssemblyName System.Windows.Forms
        \$notification = New-Object System.Windows.Forms.NotifyIcon
        \$notification.Icon = [System.Drawing.SystemIcons]::Information
        \$notification.BalloonTipTitle = '📌📌📌📌📌' 
        \$notification.BalloonTipText = '➡️ Clipboard cleared'
        \$notification.Visible = \$true
        \$notification.ShowBalloonTip(2000)

        Start-Sleep -Seconds 2
        \$notification.Dispose()
    " &>/dev/null &!
}

usudo() {
    sudo -E env PATH="$PATH" "$@"
}

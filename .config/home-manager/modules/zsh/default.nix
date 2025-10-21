{ lib, pkgs, config, ... }:

let
    # Read all .zsh files from your function directory
    p10k = pkgs.zsh-powerlevel10k;

    xdgCacheHome = if config.xdg.cacheHome != null then config.xdg.cacheHome else "$HOME/.cache";

    getZshFiles = dir:
        let
            entries = lib.filesystem.listFilesRecursive dir;
            isZshFile = path: lib.hasSuffix ".zsh" path;
            isInitFile = path: lib.hasSuffix "/init.zsh" path;
        in
        lib.filter (path: isZshFile path || isInitFile path) entries;

    sourceFiles = file: ''
        if [[ -f ${lib.escapeShellArg file} ]]; then
            . ${lib.escapeShellArg file}
        fi
    '';

    allZshFiles = 
        (getZshFiles ./functions) ++
        (getZshFiles ./extra);
in
{
    # imports = [
    #     ./extra/autocomplete.nix
    # ];

    programs.zsh = {
        enable = true;

        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        # dotDir = ".config/zsh";
        dotDir = "${config.xdg.configHome}/zsh";
        history = {
            path = "${config.xdg.configHome}/zsh/.zsh_history";
            saveNoDups = true;
        };
        historySubstringSearch.enable = true;

        shellAliases = {
            "cl" = "clear";
            "cd-proj" = "cd /mnt/wsl/PHYSICALDRIVE0p1/farid";
            # "git-new-repo" = "${config.home.homeDirectory}/.local/bin/create-repo.sh";
            "ls" = if pkgs ? eza then
                "eza --color=always --git --icons=always"
            else
                "ls --color=auto";
            "man" = "batman";
            "podman" = "podman-remote-static-linux_amd64";
        };

        envExtra = ''
            export extra_to_remove=removeLater
            export EDITOR=nvim
            export MYSHELL=zsh
            export DENO_INSTALL_ROOT="${config.xdg.configHome}/deno"
            # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
            export FZF_BASE="${pkgs.fzf}/bin/fzf"
            export VIMINIT='let $MYVIMRC="${config.xdg.configHome}/vim/vimrc" | source $MYVIMRC'
            export PNPM_HOME=/mnt/wsl/PHYSICALDRIVE0p1/.pnpm-store/v10
            LESSHISTFILE="${config.xdg.stateHome}/less/lesshst"
        '';

        plugins = [
            {
                name = "powerlevel10k";
                src = p10k;
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            } 
        ];

        loginExtra = ''
            if command -v mount_drive >/dev/null && ! mountpoint -q "/mnt/wsl/PHYSICALDRIVE0p1" >/dev/null; then
                mount_drive 
            fi
        '';

        initContent = 
            let extraFirst = lib.mkBefore ''
                # Set   PowerLevel10k cache directory at the very start
                export P10K_CACHE_DIR="${config.xdg.cacheHome}/p10k"

                printf "\n%.0s" {1..100}
                
                if [[ -r "$P10K_CACHE_DIR/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                    source "$P10K_CACHE_DIR/p10k-instant-prompt-''${(%):-%n}.zsh"
                fi

                # podman
                export XDG_RUNTIME_DIR=/run/user/$(id -u)
            ''; 
        # initExtra = ''
            extra = ''
                # Source modules 
                # take old script and source them, if doesn't want to rewrite here
                ${lib.concatMapStringsSep "\n" sourceFiles allZshFiles}

                # fpath=("${config.xdg.configHome}/zsh" $fpath)
                # autoload -Uz compinit & compinit

                # podman
                if [ ! -d "$XDG_RUNTIME_DIR" ]; then
                    sudo mkdir -p "$XDG_RUNTIME_DIR"
                    sudo chown -R "$(id -u):$(id -g)" "/run/user/$(id -u)"
                    sudo chmod 700 "$XDG_RUNTIME_DIR"
                fi

                # Load PowerLevel10k
                () {
                    local XDG_CACHE_HOME="${xdgCacheHome}/p10k"

                    # Initialize Powerlevel10k
                    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

                    [[ ! -f ${config.xdg.configHome}/zsh/.p10k.zsh ]] || . ${config.xdg.configHome}/zsh/.p10k.zsh
                }

                # if ! mountpoint -q "/mnt/wsl/PHYSICALDRIVE0p1" 2>/dev/null; then
                #     echo this should be last
                #     await "mount_drive"
                # fi
                # tmux_init

                # zshexit() { cleanup; }
                # trap 'cleanup' HUP

                # wsl2 wayland-0
                if grep -qE "(Microsoft|WSL)" /proc/version > /dev/null 2>&1; then
                    SOURCE_PATH="/mnt/wslg/runtime-dir/wayland-0"
                    TARGET_PATH="/run/user/$UID/wayland-0"

                    if [ -e "$SOURCE_PATH" ] && [ ! -e "$TARGET_PATH" ]; then
                        mkdir -p "/run/user/$UID"
                        ${pkgs.coreutils}/bin/ln -s "$SOURCE_PATH" "$TARGET_PATH"
                        echo "WSLg Wayland socket linked for Nix/Neovim."
                    fi
                fi
            '';
        in lib.mkMerge [extraFirst extra];
    };
}

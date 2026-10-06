{ lib, pkgs, config, ... }:

let
    # Read all .zsh files from your function directory
    p10k = pkgs.zsh-powerlevel10k;
    zshAsyncVersion = "1.8.6";

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
            export EDITOR=nvim
            export MYSHELL=zsh
            export DENO_INSTALL_ROOT=${config.xdg.configHome}/deno
            # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
            export FZF_BASE="${pkgs.fzf}/bin/fzf"
            export VIMINIT='let $MYVIMRC="${config.xdg.configHome}/vim/vimrc" | source $MYVIMRC'
            export NUGET_PACKAGES="/mnt/wsl/PHYSICALDRIVE0p1/farid/.local/share/nuget"
            #export PNPM_HOME=/mnt/wsl/PHYSICALDRIVE0p1/.pnpm-store/v10 
            export PNPM_HOME=/mnt/wsl/PHYSICALDRIVE0p1/farid/.local/share/pnpm/store/v10
            export LOCAL_BIN=${config.home.homeDirectory}/.local/bin
            LESSHISTFILE=${config.xdg.stateHome}/less/lesshst
        '';

        plugins = [
            {
                name = "powerlevel10k";
                src = p10k;
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
            {
                name = "zsh-async";
                src = pkgs.fetchFromGitHub {
                  owner = "mafredri";
                  repo = "zsh-async";
                  rev = "v${zshAsyncVersion}";
                  hash = "sha256-Js/9vGGAEqcPmQSsumzLfkfwljaFWHJ9sMWOgWDi0NI=";
                };
                file = "async.zsh";
            }
        ];

        loginExtra = ''
            # if command -v mount_drive >/dev/null && ! mountpoint -q "/mnt/wsl/PHYSICALDRIVE0p1" >/dev/null; then
            #     mount_drive 
            # fi
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

                # Initialize zsh-async
                # fpath=("${config.xdg.configHome}/zsh/plugins/zsh-async" $fpath)
                # autoload -Uz zsh-async && zsh-ansync
            ''; 
        # initExtra = ''
            extra = ''
                export PATH="$LOCAL_BIN:$PNPM_HOME:$PATH"
                # Source modules 
                # take old script and source them, if doesn't want to rewrite here
                ${lib.concatMapStringsSep "\n" sourceFiles allZshFiles}
                async_init
                async_start_jobs

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

                setopt HIST_IGNORE_SPACE

                # tmux_init

                # zshexit() { cleanup; }
                # trap 'cleanup' HUP
            '';
        in lib.mkMerge [extraFirst extra];
    };
}

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
    imports = [
        ./extra/autocomplete.nix
    ];

    programs.zsh = {
        enable = true;

        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        dotDir = ".config/zsh";
        history = {
            path = "${config.xdg.configHome}/zsh/.zsh_history";
            saveNoDups = true;
        };
        historySubstringSearch.enable = true;

        shellAliases = {
            "cd-proj" = "cd /mnt/wsl/PHYSICALDRIVE0p1/farid";
            "config" = "git --git-dir=${config.home.homeDirectory}/.dotfiles/ --work-tree=${config.home.homeDirectory}";
            # "git-new-repo" = "${config.home.homeDirectory}/.local/bin/create-repo.sh";
            "ls" = if pkgs ? eza then
                "eza --color=always --git --icons=always"
            else
                "ls --color=auto";
            "man" = "batman";
        };

        envExtra = ''
            export EDITOR=nvim
            export MYSHELL=zsh
            export DENO_INSTALL_ROOT="${config.xdg.configHome}/deno"
            # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
            export FZF_BASE="${pkgs.fzf}/bin/fzf"
            export VIMINIT='let $MYVIMRC="${config.xdg.configHome}/vim/vimrc" | source $MYVIMRC'
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
            if command -v mount_drive >/dev/null && ! findmnt -rno TARGET "/mnt/wsl/PHYSICALDRIVE0p1" >/dev/null; then
               mount_drive 
            fi

        '';

        initExtraFirst = ''
            # Set   PowerLevel10k cache directory at the very start
            export P10K_CACHE_DIR="${config.xdg.cacheHome}/p10k"
            
            if [[ -r "$P10K_CACHE_DIR/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                source "$P10K_CACHE_DIR/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
        '';

        initExtra = ''
            # Source modules 
            # take old script and source them, if doesn't want to rewrite here
            ${lib.concatMapStringsSep "\n" sourceFiles allZshFiles}

            fpath=("${config.xdg.configHome}/zsh" $fpath)
            autoload -Uz compinit & compinit

            # echo "Current TMUX sessions: $(tmux list-sessions 2>/dev/null)" # check tmux session
            if [[ -z "$TMUX" ]] && [[ "$SSH_CONNECTION" != "" ]]; then
                tmux attach-session -t 🤖 || tmux new-session -s 🤖
            elif [[ -z "$TMUX" ]] && [ -n "$DISPLAY" ]; then
                tmux attach-session -t 🎮 || tmux new-session -s 🎮
            fi

            # Load PowerLevel10k
            () {
                local XDG_CACHE_HOME="${xdgCacheHome}/p10k"

                # Initialize Powerlevel10k
                source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

                [[ ! -f ${config.xdg.configHome}/zsh/.p10k.zsh ]] || . ${config.xdg.configHome}/zsh/.p10k.zsh
            }
        '';
    };
}

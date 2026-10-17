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
            export DENO_INSTALL_ROOT=${config.xdg.configHome}/deno
            export EDITOR=nvim
            export FZF_BASE="${pkgs.fzf}/bin/fzf"
            export LOCAL_BIN=${config.home.homeDirectory}/.local/bin
            export MYSHELL=zsh
            export NUGET_PACKAGES="/mnt/wsl/PHYSICALDRIVE0p1/farid/.local/share/nuget"
            # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
            #export PNPM_HOME=/mnt/wsl/PHYSICALDRIVE0p1/.pnpm-store/v10 
            export PNPM_HOME=/mnt/wsl/PHYSICALDRIVE0p1/farid/.local/share/pnpm/store/v10
            export PROMPT_EOL_MARK=""
            export VIMINIT='let $MYVIMRC="${config.xdg.configHome}/vim/vimrc" | source $MYVIMRC'
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

                # cache ssh passphrase
                eval $(ssh-agent)
                ssh-add

                # tmux_init

                # zshexit() { cleanup; }
                # trap 'cleanup' HUP

                source ${config.xdg.configHome}/zsh/ssh-init.zsh
            '';
        in lib.mkMerge [extraFirst extra];
    };

    sops.templates."zsh_ssh-init" = {
      path = "${config.xdg.configHome}/zsh/ssh-init.zsh";
      mode = "0600";
      content = ''
        gopass() {
          if [[ -f "${config.sops.secrets.local_gopass_age_pass.path}" ]]; then
            export GOPASS_AGE_PASSWORD="$(< "${config.sops.secrets.local_gopass_age_pass.path}")"
          fi

          command gopass "$@"
        }

        ssh-init() {
          forgejo_flag=""
          github_flag=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
            --forgejo)
              forgejo_flag="$2"
              shift 2
              ;;
            --github)
              github_flag="$2"
              shift 2
              ;;
            *)
              shift 1
              ;;
            esac
          done

          local forgejo_filename="${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_forgejo_filename}"
          local github_filename="${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_github_filename}"
          export GOPASS_AGE_PASSWORD="$(< "${config.sops.secrets.local_gopass_age_pass.path}")"

          if [[ ! -f "$forgejo_filename" ||  "$\{forgejo_flag:l\}" == "force" ]]; then
            local forgejo_comment="${config.sops.placeholder.git_forgejo_comment}"

            if ! "$(gopass show gopass-dev/ssh/${config.sops.placeholder.git_forgejo_host}/${config.sops.placeholder.git_forgejo_filename})" &>/dev/null; then
              echo "Generating default passphrase for forgejo in gopass..."

              gopass generate gopass-dev/ssh/${config.sops.placeholder.git_forgejo_host}/${config.sops.placeholder.git_forgejo_filename} ${config.sops.placeholder.git_forgejo_pass_length}
            fi

            local passphrase="$(mygp gopass-dev/ssh/${config.sops.placeholder.git_forgejo_host}/${config.sops.placeholder.git_forgejo_filename} | jq -r ".password")"

            ssh-keygen -t ed25519 -f "$forgejo_filename" -N "$passphrase" -a 100 -C "$forgejo_comment"
          else
            echo "😀: $forgejo_filename already exist. To overwrite it; run \"ssh-init --forgejo force\""
          fi

          if [[ ! -f "$github_filename" ||  "$\{github_flag:l\}" == "force" ]]; then
            local github_comment="${config.sops.placeholder.git_github_comment}"

            if ! "$(gopass show gopass-dev/ssh/${config.sops.placeholder.git_github_host}/${config.sops.placeholder.git_github_filename})" &>/dev/null; then
              echo "Generating default passphrase for github in gopass..."

              gopass generate gopass-dev/ssh/${config.sops.placeholder.git_github_host}/${config.sops.placeholder.git_github_filename} ${config.sops.placeholder.git_github_pass_length}
            fi

            local passphrase="$(mygp gopass-dev/ssh/${config.sops.placeholder.git_github_host}/${config.sops.placeholder.git_github_filename} | jq -r ".password")"

            ssh-keygen -t ed25519 -f "$github_filename" -N "$passphrase" -a 100 -C "$github_comment"
          else
            echo "😀: $github_filename already exist. To overwrite it; run \"ssh-init --github force\""
          fi
        }

        ssh-pass-change() {
          local new_pass=""
          local target_ind=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
            -p)
              new_pass="$2"
              shift 2
              ;;
            -t)
              target_ind="$2"
              shift 2
              ;;
            *)
              shift 1
              ;;
            esac
          done

          if [[ -z "$new_pass" || -z "$target_ind" ]]; then
            echo "ERROR: usage: ssh-pass-change -p <new_pass> -t <1:github|2:forgejo>"
            return 1
          fi

          export GOPASS_AGE_PASSWORD="$(< "${config.sops.secrets.local_gopass_age_pass.path}")"
          local target_platform=("github" "forgejo")
          local platform="$target_platform[$target_ind]"
          echo "target_ind: $target_ind"
          echo "platform: $platform"

          local pass_target=""
          local key_target=""

          if [[ "$platform" == "github" ]]; then
            pass_target="gopass-dev/ssh/${config.sops.placeholder.git_github_host}/${config.sops.placeholder.git_github_filename}"
            key_target="${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_github_filename}"
          elif [[ "$platform" == "forgejo" ]]; then
            pass_target="gopass-dev/ssh/${config.sops.placeholder.git_forgejo_host}/${config.sops.placeholder.git_forgejo_filename}" 
            key_target="${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_forgejo_filename}"
          else
            echo "ERROR: Invalid target index. Use 1 for github, 2 for forgejo"
            return 1
          fi

          local old_passphrase="$(mygp "$pass_target" | jq -r ".password")"

          echo "Updating SSH key passphrase for $key_target..."
          ssh-keygen -p -f "$key_target" -P "$old_passphrase" -N "$new_pass"

          if [[ $? -eq 0 ]]; then
            gopass insert --force "$pass_target" <<< "$new_pass"
            echo "✅: Password for $pass_target and "$ssh_file_target" updated."
          else
            echo "❌: Failed to update SSH key passphrase."
            return 1
          fi
        }
      '';
    };
}

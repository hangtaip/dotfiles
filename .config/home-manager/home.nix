{ config, pkgs, ... }:

{
    imports = [
        ./modules/zsh/default.nix
    ];

    home.username = "farid";
    home.homeDirectory = "/home/farid";

    home.packages = with pkgs; [
        bat
        bc
        clang
        delta
        deno
        eza
        fd
        fzf
        git-credential-gopass
        gnupg
        gh
        gopass
        jq
        neovim
        nix-direnv
        nixd
        noto-fonts-color-emoji
        ripgrep
        shellcheck
        tlrc
        unzip
        xclip
        zoxide
        zsh
        
    ];

    home.stateVersion = "24.11";

    nix.gc = {
        automatic = true;
        frequency = "weekly";
        options = "--delete-older-than 7d";
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
        bat = {
            enable = true;
            themes = {
                tokyonight_night = {
                    src = pkgs.fetchFromGitHub {
                        owner = "folke";
                        repo = "tokyonight.nvim";
                        rev = "057ef5d260c1931f1dffd0f052c685dcd14100a3";
                        sha256 = "002rzmdxq45bdyd27i8k8lhdcwxn9l4v6x5cm6g7v1213m0n25np";
                    };
                    file = "extras/sublime/tokyonight_night.tmTheme";
                };
            };
            extraPackages = with pkgs.bat-extras; [
              batman
            ];
            config = {
                theme = "tokyonight_night";
                pager = "less -FR";
            };
        };

        direnv = {
            enable = true;
            nix-direnv.enable = true; 
        };

        fzf.enable = true;

        git = {
            enable = true;
            userName = "hangtaip";
            userEmail = "hangtaip.stabilize940@passinbox.com";
            delta = {
                enable = true;
                options = {
                    navigate = true;
                    side-by-side = true;
                };
            };
            extraConfig = {
                core = {
                    editor = "${pkgs.neovim}/bin/nvim";
                };
                credential = {
                    helper = "gopass";
                };
                diff = {
                    colorMoved = "default";
                };
                init = {
                    defaultBranch = "main";
                };
                merge = {
                    conflictstyle = "diff3"; 
                };
            };
        };

        gpg = {
            enable = true;
        };

        tmux = {
            enable = true;
            terminal = "screen-256color";
            prefix = "C-space";
            keyMode = "vi";
            baseIndex = 1;
            escapeTime = 10;    
            mouse = true;
            plugins = with pkgs; [ 
                tmuxPlugins.vim-tmux-navigator
                tmuxPlugins.yank
                {
                    plugin = tmuxPlugins.resurrect;
                    extraConfig = ''
                        set -g @resurrect-strategy-nvim 'session'
                        set -g @resurrect-capture-pane-contents 'on'
                    '';
                }
                {
                    plugin = tmuxPlugins.continuum;
                    extraConfig = ''
                        set -g @continuum-restore 'on'
                        set -g @continuum-save-internal '60'
                    '';
                }
                {
                    plugin = tmuxPlugins.tokyo-night-tmux;
                    extraConfig = ''
                        # number styles
                        set -g @tokyo-night-tmux_window_id_style roman 
                        set -g @tokyo-night-tmux_pane_id_style hsquare
                        set -g @tokyo-night-tmux_zoom_id_style dsquare

                        # widget
                        set -g @tokyo-night-tmux_show_netspeed 1
                        set -g @tokyo-night-tmux_netspeed_iface "eth0" 
                        set -g @tokyo-night-tmux_netspeed_showip 1      
                        set -g @tokyo-night-tmux_netspeed_refresh 1     
                    '';
                }
            ];
            extraConfig = ''
                set -ag terminal-overrides ",*256col*:RGB"
                unbind %
                bind | split-window -h -c "#{pane_current_path}"

                unbind '"'
                bind - split-window -v -c "#{pane_current_path}"

                unbind r
                bind r source-file "${config.xdg.configHome}/tmux/tmux.conf"

                bind j resize-pane -D 5
                bind k resize-pane -U 5
                bind l resize-pane -R 5
                bind h resize-pane -L 5

                bind -r m resize-pane -Z

                bind-key -T copy-mode-vi 'v' send -X begin-selection 
                bind-key -T copy-mode-vi 'C-q' send -X rectangle-toggle
                bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
                bind-key -T copy-mode-vi 'Y' send -X copy-line

                unbind ] 
                unbind -T copy-mode-vi MouseDragEnd1Pane
            '';
        };

        zoxide.enable = true;
    };
    
    programs.home-manager.enable = true;

    services.gpg-agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
    };
}

{ config, pkgs, ... }:

{
    imports = [
        ./modules/zsh/default.nix
        ./modules/tmux/default.nix
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
	pinentry-curses
        ripgrep
        shellcheck
        tlrc
        tmux
        unzip
        xclip
        zip
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

        zoxide.enable = true;
    };
    
    programs.home-manager.enable = true;

    services.gpg-agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
        # extraConfig = ''
        #     RefuseManualStart = false
        # '';
    };
}

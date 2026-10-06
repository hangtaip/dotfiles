{ config, pkgs, pkgs-unstable, ... }:

{
    imports = [
        ./modules/sops/default.nix
        ./modules/zsh/default.nix
        ./modules/tmux/default.nix
        ./modules/lazysql/default.nix
    ];

    home.username = "farid";
    home.homeDirectory = "/home/farid";

    home.packages = (with pkgs; [
        age
        bat
        bc
        clang
        delta
        deno
        eza
        fd
        fzf
        git-credential-gopass
        gh
        gnumake
        gnupg
        gopass
        grpcurl
        lazysql
        luarocks
        lua51Packages.lua
        jq
        nix-direnv
        nixd
        ncdu
        noto-fonts-color-emoji
	     pinentry-curses
        ripgrep
        shellcheck
        sops
        tlrc
        tmux
        unzip
        uv
        wl-clipboard
        zip
        zoxide
        zsh
    ])

    ++

    (with pkgs-unstable; [
      neovim
    ]);

    home.stateVersion = "26.05";

    # nix.gc = {
    #     automatic = true;
    #     dates = "weekly";
    #     # options = "--delete-older-than 6d";
    #     options = "-d";
    # };

    nixpkgs.config.allowUnfree = true;
    
    xdg.enable = true;

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

        delta = {
            enable = true;
            enableGitIntegration = true;
            options = {
                  navigate = true;
                  side-by-side = true;
            };
        };

        direnv = {
            enable = true;
            nix-direnv.enable = true; 
        };

        fzf.enable = true;

        git = {
            enable = true;
            settings = {
                user = {
                    name = "hangtaip";
                    email = "hangtaip.stabilize940@passinbox.com";
                };
                core = {
                    editor = "${pkgs-unstable.neovim}/bin/nvim";
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
        pinentry.package = pkgs.pinentry-curses;
        # extraConfig = ''
        #     RefuseManualStart = false
        # '';
    };
}

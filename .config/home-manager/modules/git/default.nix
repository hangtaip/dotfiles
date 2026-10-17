{ lib, pkgs, pkgs-unstable, config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
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
        commit = {
          gpgsign = true;
        };
        gpg = {
          format = "ssh";
        };
    };
    includes = [
        {
          condition = "hasconfig:remote.*.url:forgejo.hangtaip.dev:*/**";
          path = "${config.xdg.configHome}/git/config-user-forgejo";
        }
        {
          condition = "hasconfig:remote.*.url:https://github.com/**";
          path = "${config.xdg.configHome}/git/config-user-standard";
        }
        {
          path = "${config.xdg.configHome}/git/config-alias";
        }
    ];
  };

  sops.templates."git-config-user-standard" = {
    path = "${config.xdg.configHome}/git/config-user-standard";
    mode = "0600";
    content = ''
        [user]
            name = ${config.sops.placeholder.git_github_name}
            email = ${config.sops.placeholder.git_github_email}
            signingkey = ${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_github_filename}.pub
    '';
  };

  sops.templates."git-config-user-forgejo" = {
    path = "${config.xdg.configHome}/git/config-user-forgejo";
    mode = "0600";
    content = ''
        [user]
            name = ${config.sops.placeholder.git_forgejo_name}
            email = ${config.sops.placeholder.git_forgejo_email}
            signingkey = ${config.home.homeDirectory}/.ssh/${config.sops.placeholder.git_forgejo_filename}.pub
    '';
  };
  
  sops.templates."git-config-alias" = {
    path = "${config.xdg.configHome}/git/config-alias";
    mode = "0600";
    content = ''
        [alias]
            crh = changeremotehost
            changeremotehost = !sh -c \"git remote -v | grep '$1.*fetch' | sed s/...fetch.// | sed s/$1/$2/ | xargs git remote set-url\"
            setforgejomail = "config user.email '${config.sops.placeholder.git_forgejo_email}'"
            setforgejoname = "config user.name '${config.sops.placeholder.git_forgejo_name}'"
            goforgejo = !sh -c \"git changeremotehost github.com ${config.sops.placeholder.git_forgejo_host} && git setforgejoname && git setforgejoemail\"
    '';
  };
}

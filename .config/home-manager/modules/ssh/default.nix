{ lib, pkgs, pkgs-unstable, config, ... }:

{
  sops.templates."ssh-config" = {
    path = "${config.home.homeDirectory}/.ssh/config";

    mode = "0600";

    content = ''
      Host ${config.sops.placeholder.git_github_host}
        HostName ${config.sops.placeholder.git_github_hostname}
        User ${config.sops.placeholder.git_github_user}
        Port ${config.sops.placeholder.git_github_port}
        IdentityFile ${config.sops.placeholder.git_github_identityfile}
        IdentitiesOnly ${config.sops.placeholder.git_github_identitiesonly}

      Host ${config.sops.placeholder.git_forgejo_host}
        HostName ${config.sops.placeholder.git_forgejo_hostname}
        User ${config.sops.placeholder.git_forgejo_user}
        Port ${config.sops.placeholder.git_forgejo_port}
        IdentityFile ${config.sops.placeholder.git_forgejo_identityfile}
        IdentitiesOnly ${config.sops.placeholder.git_forgejo_identitiesonly}
      '';
  };
}

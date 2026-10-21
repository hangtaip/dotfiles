{ lib, pkgs, config, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
      # postgresql
      development_database_postgres_user = {};
      development_database_postgres_pass = {};
      local_gopass_age_pass = {};
      mnt_projects_dir = {};
      mnt_projects_javascript_dir = {};
      # git
      git_github_filename = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_pass_length = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_comment = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_name = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_email = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_host = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_hostname = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_user = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_port = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_identityfile = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_github_identitiesonly = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_filename = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_pass_length = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_comment = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };     
      git_forgejo_name = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_email = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_host = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_hostname = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_user = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_port = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_identityfile = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
      git_forgejo_identitiesonly = {
        sopsFile = ../../secrets/secrets-git.yaml;
      };
    };
  };
}

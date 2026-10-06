{ lib, pkgs, config, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
      development_database_postgres_user = {};
      development_database_postgres_pass = {};
    };
  };
}

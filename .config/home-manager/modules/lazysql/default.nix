{ lib, pkgs, config, ... }:

{
  programs.lazysql = {
      enable = true;
    };

  sops.templates."lazysql-config.toml" = {
    path = "${config.xdg.configHome}/lazysql/config.toml";

    mode = "0600";

    content = ''
      [[database]]
      Name = 'postgres:Adventureworks'
      URL = 'postgres://${config.sops.placeholder.development_database_postgres_user}:${config.sops.placeholder.development_database_postgres_pass}@localhost:5432/Adventureworks?sslmode=disable'
      Provider = 'postgres'
      DBName = 'Adventureworks'

      [[database]]
      Name = 'postgres:TodoApp'
      URL = 'postgres://${config.sops.placeholder.development_database_postgres_user}:${config.sops.placeholder.development_database_postgres_pass}@localhost:5432/todo_db?sslmode=disable'
      Provider = 'postgres'
      DBName = 'todo_db'

      [[database]]
      Name = 'sqlite:web-dotnet/TodoApp'
      URL = 'file:/mnt/wsl/PHYSICALDRIVE0p1/farid/projects/web-dotnet/TodoApp/src/TodoApp/Infrastructure/Data/TodoAppSQLite.db?loc=auto'
      Provider = 'sqlite3'
      '';
  };
}

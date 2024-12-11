{ config, pkgs, lib, ... }:

let
  mdBook-server = config.services.merlin.mdBook-server;
in
{
  options.services.merlin.mdBook-server = {
    package = lib.mkPackageOption pkgs "mdbook" { };

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the mdBook server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port used by 'mdbook serve'.";
    };

    src = lib.mkOption {
      type = lib.types.path;
      description = "Source directory for the mdBook.";
    };
  };

  config =
    let
      mdbook-serve = ''
        ${mdBook-server.package}/bin/mdbook serve -p ${builtins.toString mdBook-server.port} ${mdBook-server.src}
      '';
    in
    lib.mkIf mdBook-server.enable {
      systemd.services.merlin-mdBook-server = {
        description = mdbook-serve;

        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = mdbook-serve;

          Restart = "always";

          RestartSec = "2s";
        };
      };
    };
}

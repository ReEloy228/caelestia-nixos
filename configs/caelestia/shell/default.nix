{
  lib,
  pkgs,
  mod,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cleanSettings = removeAttrs mod.settings [ "mutable" ];
  jsonConfig = jsonFormat.generate "caelestia-shell.json" cleanSettings;
in
{
  config = {
    programs.caelestia.settings = mod.settings;

    xdg.configFile."caelestia/shell.json".enable = lib.mkForce false;

    home.activation.caelestiaShellJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.config/caelestia
      $DRY_RUN_CMD cp --remove-destination ${jsonConfig} $HOME/.config/caelestia/shell.json
      $DRY_RUN_CMD chmod 644 $HOME/.config/caelestia/shell.json
    '';
  };
}

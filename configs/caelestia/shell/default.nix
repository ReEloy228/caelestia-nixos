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

    xdg.configFile."caelestia/shell.json" = {
      source = jsonConfig;
      force = true;
    };

    home.activation.caelestiaCleanBackup = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      $DRY_RUN_CMD rm -f "$HOME/.config/caelestia/shell.json.hm-backup"
    '';

    home.activation.caelestiaWritableShellConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ -L "$HOME/.config/caelestia/shell.json" ]; then
        $DRY_RUN_CMD cp --remove-destination \
          "$(readlink -f "$HOME/.config/caelestia/shell.json")" \
          "$HOME/.config/caelestia/shell.json"
      fi
    '';
  };
}

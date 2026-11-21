{
  lib,
  pkgs,
  mod,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };

  resolveOverrides =
    value:
    if builtins.isAttrs value then
      if value ? __override then
        resolveOverrides value.__override
      else if value ? __append then
        resolveOverrides value.__append
      else if value ? __prepend then
        resolveOverrides value.__prepend
      else
        builtins.mapAttrs (_name: val: resolveOverrides val) value
    else if builtins.isList value then
      map resolveOverrides value
    else
      value;

  cleanSettings = removeAttrs mod.settings [ "mutable" ];
  resolvedSettings = resolveOverrides cleanSettings;
  jsonConfig = jsonFormat.generate "caelestia-shell.json" resolvedSettings;
in
{
  config = {
    xdg.configFile."caelestia/shell.json".enable = lib.mkForce false;

    home.activation.caelestiaShellJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.config/caelestia
      $DRY_RUN_CMD cp --remove-destination ${jsonConfig} $HOME/.config/caelestia/shell.json
      $DRY_RUN_CMD chmod 644 $HOME/.config/caelestia/shell.json
    '';
  };
}

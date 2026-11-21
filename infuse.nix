{ lib }:
let
  sugars =
    _infuse.v1.default-sugars
    ++ lib.attrsToList {
      __remove =
        path: remove: target:
        lib.filter (tg: !lib.any (r: lib.hasPrefix r tg) remove) target;
      __replace =
        path: replace: target:
        with lib.lists;
        let
          froms = flatten (map (frs: dropEnd 1 frs) replace);
          tos = flatten (map (ts: replicate (builtins.length ts - 1) (last ts)) replace);
        in
        if isList target then
          (map (tg: builtins.replaceStrings froms tos tg) target)
        else
          builtins.replaceStrings froms tos target;
    };
  _infuse =
    import
      (fetchGit {
        url = "https://codeberg.org/amjoseph/infuse.nix";
        name = "infuse.nix";
        rev = "c8fb7397039215e1444c835e36a0da7dc3c743f8";
      })
      {
        inherit lib sugars;
      };

  inherit (_infuse.v1) infuse;

  wrapSettingsToInfusion =
    let
      isSugar = name: lib.any (s: s.name == name) sugars;
      isSpecial = lib.hasPrefix "__";

      isValidAttrs =
        value:
        with lib;
        let
          attrNames = builtins.attrNames value;
          sugarCount = count isSugar attrNames;
          hasSpecial = any isSpecial attrNames;
        in
        isAttrs value && ((sugarCount == 0 && !hasSpecial) || sugarCount == lists.length attrNames);

      transformToInfusion =
        name: value:
        if (lib.isFunction value) || (isSugar name && !lib.isAttrs value) || name == "__assign" then
          value
        else if isValidAttrs value then
          lib.mapAttrs (n: v: transformToInfusion n v) value
        else if lib.isList value then
          { __append = value; }
        else
          { __assign = value; };
    in
    transformToInfusion;
in
default: userSettings:
if default != userSettings && userSettings != { } then
  infuse default (wrapSettingsToInfusion "" userSettings)
else
  default

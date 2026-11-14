{ lib, ... }:
let
  inherit (lib) mkOption types;

  # ── Хелперы для устранения DRY-нарушений ──────────────────────────

  mkScaleOpt =
    default: description:
    mkOption {
      type = types.oneOf [
        types.int
        types.float
      ];
      inherit default description;
    };

  mkToggleOpt =
    default: description:
    mkOption {
      type = types.bool;
      inherit default description;
    };

  mkDragThresholdOpt =
    default:
    mkOption {
      type = types.int;
      inherit default;
      description = "Порог drag-жеста в пикселях";
    };

  # Типизированная запись бар-виджета
  barEntryType = types.submodule {
    options = {
      id = mkOption {
        type = types.str;
        description = "Идентификатор виджета (logo, workspaces, spacer, clock, и т.д.)";
      };
      enabled = mkToggleOpt true "Показывать этот виджет";
    };
  };

  # Типизированная запись действия лаунчера
  launcherActionType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Отображаемое имя действия";
      };
      icon = mkOption {
        type = types.str;
        description = "Имя Material Symbols иконки";
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = "Описание действия";
      };
      command = mkOption {
        type = types.listOf types.str;
        description = "Команда для выполнения";
      };
      dangerous = mkToggleOpt false "Требует подтверждения перед выполнением";
      enabled = mkToggleOpt true "Включить это действие";
    };
  };

  # Типизированная запись уровня предупреждения батареи
  batteryWarnLevelType = types.submodule {
    options = {
      level = mkOption {
        type = types.int;
        description = "Процент заряда для срабатывания";
      };
      icon = mkOption {
        type = types.str;
        description = "Имя иконки";
      };
      title = mkOption {
        type = types.str;
        description = "Заголовок уведомления";
      };
      message = mkOption {
        type = types.str;
        description = "Текст уведомления (поддерживает HTML)";
      };
      critical = mkToggleOpt false "Критический уровень — агрессивное уведомление";
    };
  };

  # Типизированная запись таймаута простоя
  idleTimeoutType = types.submodule {
    options = {
      timeout = mkOption {
        type = types.int;
        description = "Таймаут в секундах";
      };
      idleAction = mkOption {
        type = types.oneOf [
          types.str
          (types.listOf types.str)
        ];
      };
      returnAction = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      enabled = mkToggleOpt true "Включен ли таймаут";
      inhibitWhenAudio = mkToggleOpt false "Не срабатывать при аудио";
      inhibitWhenCharging = mkToggleOpt false "Не срабатывать при зарядке";
      respectInhibitors = mkToggleOpt true "Уважать инхибиторы (например, видео)";
    };
  };

  # Типизированная запись специальной иконки воркспейса
  specialWsIconType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Имя специального воркспейса";
      };
      icon = mkOption {
        type = types.str;
        description = "Material Symbols иконка";
      };
      flags = mkOption {
        type = types.str;
        default = "";
        description = "Флаги regex";
      };
      regex = mkOption {
        type = types.str;
        default = "";
        description = "Regex для сопоставления";
      };
    };
  };

  # Типизированная запись алиаса плеера
  playerAliasType = types.submodule {
    options = {
      from = mkOption {
        type = types.str;
        description = "Оригинальный идентификатор";
      };
      to = mkOption {
        type = types.str;
        description = "Отображаемое имя";
      };
    };
  };

  # Типизированная запись VPN-провайдера
  vpnProviderType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      interface = mkOption { type = types.str; };
      displayName = mkOption { type = types.str; };
      id = mkOption {
        type = types.str;
        default = "";
      };
      connectCmd = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      disconnectCmd = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  # Типизированная запись подстановки иконки трея
  iconSubType = types.submodule {
    options = {
      from = mkOption {
        type = types.str;
        description = "Исходное имя иконки";
      };
      to = mkOption {
        type = types.str;
        description = "Целевое имя иконки";
      };
    };
  };

  # Хелпер для создания записи бар-виджета (устраняет DRY-повторы)
  mkEntry = id: {
    inherit id;
    enabled = true;
  };

  # Хелпер для быстрого создания действия лаунчера
  mkAction =
    {
      name,
      icon,
      description ? "",
      command,
      dangerous ? false,
      enabled ? true,
    }:
    {
      inherit
        name
        icon
        description
        command
        dangerous
        enabled
        ;
    };

  # Команда сессии — единый источник правды (устраняет дублирование session ↔ launcher)
  sessionCommands = {
    shutdown = [
      "systemctl"
      "poweroff"
    ];
    reboot = [
      "systemctl"
      "reboot"
    ];
    logout = [
      "loginctl"
      "terminate-user"
      ""
    ];
    hibernate = [
      "systemctl"
      "hibernate"
    ];
    sleep = [
      "systemctl"
      "suspend-then-hibernate"
    ];
    lock = [
      "loginctl"
      "lock-session"
    ];
  };

in
{
  inherit
    mkScaleOpt
    mkToggleOpt
    mkDragThresholdOpt
    mkEntry
    mkAction
    sessionCommands
    barEntryType
    launcherActionType
    batteryWarnLevelType
    idleTimeoutType
    specialWsIconType
    playerAliasType
    vpnProviderType
    iconSubType
    ;
}

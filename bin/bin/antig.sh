
#!/bin/bash

readonly UNIT_NAME="antigravity-$(date +%s)"
readonly -a APP_BIN=(/usr/bin/antigravity --verbose)
readonly TRIGGER="Lifecycle#onWillShutdown - end 'antigravityAnalytics'"

# Forward all optional params (for example '.' or '~/web/project') to antigravity.
APP_ARGS=("${APP_BIN[@]}" "$@")

echo "[*] Start as: $UNIT_NAME"

UNIT_NAME="$UNIT_NAME" systemd-run --user \
    --scope \
    --unit="$UNIT_NAME" \
    --property=KillMode=control-group \
    /bin/bash -c 'exec prlimit --core=0 "$@" 2>&1 | systemd-cat --identifier="$UNIT_NAME"' bash "${APP_ARGS[@]}" &

journalctl --user --identifier="$UNIT_NAME" --follow | \
    grep --line-buffered --max-count=1 "$TRIGGER" && \
    systemctl --user kill --signal=SIGKILL "$UNIT_NAME.scope"

echo "[*] Remaining processes are killed."

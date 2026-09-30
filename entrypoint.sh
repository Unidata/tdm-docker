#!/bin/bash
set -euo pipefail

if [ "${1:-}" = 'tdm.sh' ]; then

    USER_ID=${TDM_USER_ID:-1000}
    GROUP_ID=${TDM_GROUP_ID:-1000}

    if ! [[ "$USER_ID" =~ ^[0-9]+$ && "$GROUP_ID" =~ ^[0-9]+$ ]]; then
        echo "TDM_USER_ID and TDM_GROUP_ID must be numeric" >&2
        exit 1
    fi

    if ! getent group "$GROUP_ID" > /dev/null; then
        groupadd --system --gid "$GROUP_ID" tdm
    fi
    if ! getent passwd "$USER_ID" > /dev/null; then
        useradd --uid "$USER_ID" --gid "$GROUP_ID" \
            --home-dir "$TDM_HOME" --shell /usr/sbin/nologin \
            --comment "TDM user" tdm
    fi

    chown -R "$USER_ID:$GROUP_ID" "$TDM_HOME/logs" "$TDM_HOME/.java"
    exec gosu "$USER_ID:$GROUP_ID" "$@"
fi

exec "$@"

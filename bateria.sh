#!/bin/bash

# Validar variables
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Faltan variables de entorno TELEGRAM_TOKEN o TELEGRAM_CHAT_ID"
    exit 1
fi

BAT_PATH="/sys/class/power_supply"
CHECK_INTERVAL=30
HOST=$(hostname)

STATE_FILE="/tmp/power_monitor_state"

send_telegram() {
    local MESSAGE="$1"

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE" > /dev/null
}

# Estado inicial
LAST_STATE="unknown"
[ -f "$STATE_FILE" ] && LAST_STATE=$(cat $STATE_FILE)

while true; do
    BAT=$(ls $BAT_PATH | grep BAT | head -n1)
    AC=$(ls $BAT_PATH | grep -E 'AC|ADP' | head -n1)

    CAPACITY=$(cat $BAT_PATH/$BAT/capacity 2>/dev/null)
    AC_STATUS=$(cat $BAT_PATH/$AC/online 2>/dev/null)

    CURRENT_STATE="normal"

    # ⚠️ Caso 1: batería baja < 20% y desconectado
    if [ "$AC_STATUS" = "0" ] && [ "$CAPACITY" -lt 20 ]; then
        CURRENT_STATE="low_battery"

        if [ "$LAST_STATE" != "$CURRENT_STATE" ]; then
            MSG="🔋⚠️ $HOST: Batería baja (${CAPACITY}%) y SIN cargador"
            send_telegram "$MSG"
        fi
    fi

    # 🔌 Caso 2: cargador conectado y batería < 50%
    if [ "$AC_STATUS" = "1" ] && [ "$CAPACITY" -lt 50 ]; then
        CURRENT_STATE="charging_low"

        if [ "$LAST_STATE" != "$CURRENT_STATE" ]; then
            MSG="🔌 $HOST: Cargador conectado (${CAPACITY}%)"
            send_telegram "$MSG"
        fi
    fi

    # Guardar estado
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        echo "$CURRENT_STATE" > "$STATE_FILE"
        LAST_STATE="$CURRENT_STATE"
    fi

    sleep $CHECK_INTERVAL
done

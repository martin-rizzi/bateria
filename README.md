# bateria

Script de bash que monitorea la batería del sistema y envía notificaciones a Telegram.

## Notificaciones

- **Batería baja**: avisa cuando la batería está por debajo del 20% y no hay cargador conectado.
- **Cargador conectado**: avisa cuando se conecta el cargador con la batería por debajo del 50%.

Las notificaciones solo se envían cuando el estado cambia, no de forma repetitiva.

## Requisitos

- `curl`
- Un bot de Telegram con su token y chat ID

## Configuración

Exportar las variables de entorno antes de ejecutar:

```bash
export TELEGRAM_TOKEN="tu_token_del_bot"
export TELEGRAM_CHAT_ID="tu_chat_id"
```

## Uso

```bash
chmod +x bateria.sh
./bateria.sh
```

Para ejecutarlo en segundo plano al iniciar sesión, agregar a `~/.profile` o usar un servicio de systemd:

```ini
[Unit]
Description=Monitor de batería

[Service]
ExecStart=/ruta/a/bateria.sh
Environment=TELEGRAM_TOKEN=tu_token
Environment=TELEGRAM_CHAT_ID=tu_chat_id
Restart=always

[Install]
WantedBy=default.target
```

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: loki systemd service requires root privileges" >&2
    exit 1
fi

servicefile() {
cat <<-_EOF_ | tee /etc/systemd/system/loki.service > /dev/null
[Unit]
Description=Loki service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/loki -config.file /etc/loki/loki-config.yml

[Install]
WantedBy=multi-user.target
_EOF_
}

servicefile
systemctl daemon-reload

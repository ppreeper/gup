if [ "$(id -u)" -ne 0 ]; then
    echo "Error: promtail systemd service requires root privileges" >&2
    exit 1
fi

servicefile() {
cat <<-_EOF_ | tee /etc/systemd/system/promtail.service > /dev/null
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/promtail-config.yml

[Install]
WantedBy=multi-user.target
_EOF_
}

servicefile
systemctl daemon-reload

function servicefile() {
cat <<-_EOF_ | sudo tee /etc/systemd/system/promtail.service > /dev/null
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
sudo systemctl daemon-reload
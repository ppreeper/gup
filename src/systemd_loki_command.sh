function servicefile() {
cat <<-_EOF_ | sudo tee /etc/systemd/system/loki.service > /dev/null
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
sudo systemctl daemon-reload
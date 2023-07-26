sudo wget https://packages.grafana.com/gpg.key -O /etc/apt/trusted.gpg.d/grafana.gpg.asc
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update -y && sudo apt install -y grafana && sudo systemctl enable grafana-server
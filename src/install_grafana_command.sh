set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: grafana requires root privileges for apt-based install" >&2
    exit 1
fi

wget -q https://packages.grafana.com/gpg.key -O /etc/apt/trusted.gpg.d/grafana.gpg.asc
echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
apt update -y && apt install -y grafana && systemctl enable grafana-server

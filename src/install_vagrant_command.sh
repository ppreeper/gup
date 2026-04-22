set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: vagrant requires root privileges for apt-based install" >&2
    exit 1
fi

lsb=$(grep VERSION_CODENAME /etc/os-release | awk -F'=' '{print $2}')
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${lsb} main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y && apt install -y vagrant

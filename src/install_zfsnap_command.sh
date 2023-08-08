APP="zfsnap"
REPO="https://github.com/zfsnap/zfsnap"
BREPO="https://raw.githubusercontent.com/zfsnap/zfsnap"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/v2.*[0-9]$" | grep -v -e rc -e alpha | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

sudo mkdir -p /usr/share/zfsnap/commands
sudo wget -qc -O /usr/share/zfsnap/core.sh "${BREPO}/${vers}/share/zfsnap/core.sh"
sudo wget -qc -O /usr/share/zfsnap/commands/destroy.sh "${BREPO}/${vers}/share/zfsnap/commands/destroy.sh"
sudo wget -qc -O /usr/share/zfsnap/commands/recurseback.sh "${BREPO}/${vers}/share/zfsnap/commands/recurseback.sh"
sudo wget -qc -O /usr/share/zfsnap/commands/snapshot.sh "${BREPO}/${vers}/share/zfsnap/commands/snapshot.sh"
sudo wget -qc -O /usr/sbin/zfsnap "${BREPO}/${vers}/sbin/zfsnap.sh"
sudo chmod +x /usr/share/zfsnap/core.sh
sudo chmod +x /usr/share/zfsnap/commands/destroy.sh
sudo chmod +x /usr/share/zfsnap/commands/recurseback.sh
sudo chmod +x /usr/share/zfsnap/commands/snapshot.sh
sudo chmod +x /usr/sbin/zfsnap
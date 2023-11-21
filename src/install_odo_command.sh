REPO="https://raw.githubusercontent.com/ppreeper/odo"

if [ $(id -u) == 0 ]; then
  IDIR="/usr/local/bin"
  sudo wget -q ${REPO}/main/odo -O ${IDIR}/odo
  chmod +x ${IDIR}/odo
else
  IDIR="${HOME}/.local/bin"
  wget -q ${REPO}/main/odo -O ${IDIR}/odo
  chmod +x ${IDIR}/odo
fi
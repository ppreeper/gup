REPO="https://raw.githubusercontent.com/ppreeper/oda"

if [ $(id -u) == 0 ]; then
  IDIR="/usr/local/bin"
  sudo wget -q ${REPO}/main/oda -O ${IDIR}/oda
  sudo wget -q ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
  chmod +x ${IDIR}/oda
  chmod +x ${IDIR}/oda_db.py
else
  IDIR="${HOME}/.local/bin"
  wget -q ${REPO}/main/oda -O ${IDIR}/oda
  wget -q ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
  chmod +x ${IDIR}/oda
  chmod +x ${IDIR}/oda_db.py
fi
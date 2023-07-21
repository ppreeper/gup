REPO="https://raw.githubusercontent.com/ppreeper/oda"
USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')

if [ ${USERIDNUMBER} == 0 ]; then
  IDIR="/usr/local/bin"
  sudo wget -q ${REPO}/main/oda -O ${IDIR}/oda
  sudo wget -q ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
else
  IDIR="${HOME}/.local/bin"
  wget -q ${REPO}/main/oda -O ${IDIR}/oda
  wget -q ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
fi
REPO="https://raw.githubusercontent.com/ppreeper/gup"
USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')

if [ ${USERIDNUMBER} == 0 ]; then
  IDIR="/usr/local/bin"
  sudo wget -q ${REPO}/main/gup -O ${IDIR}/gup
else
  IDIR="${HOME}/.local/bin"
  wget -q ${REPO}/main/gup -O ${IDIR}/gup
fi
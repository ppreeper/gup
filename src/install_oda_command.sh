echo "# this file is located in 'src/install_oda_command.sh'"
echo "# code for 'gup install oda' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args
REPO="https://raw.githubusercontent.com/ppreeper/oda"
USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')

if [ ${USERIDNUMBER} == 0 ]; then
  IDIR="/usr/local/bin"
  sudo wget ${REPO}/main/oda -O ${IDIR}/oda
  sudo wget ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
else
  IDIR="${HOME}/.local/bin"
  wget ${REPO}/main/oda -O ${IDIR}/oda
  wget ${REPO}/main/oda_db.py -O ${IDIR}/oda_db.py
fi
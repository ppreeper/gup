REPO="https://github.com/grafana/loki"
DURL="https://github.com/grafana/loki/releases/download"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)
TAGFILTER="refs/tags"
APP="loki-linux-amd64"
APPBIN=$(which ${APP})
APPVER="${APPBIN} --version | grep -i ^${APP} | awk '{print \$2}'"

BDIR="/usr/local/bin"
GLS="git ls-remote --tags ${REPO}"
TGS="grep ${TAGFILTER}"
TFIELD="awk '{print \$2}'"
RCFILT="grep -v -e \"{}\$\" -e alpha -e beta -e \"[Rr][Cc].*\$\""
TGTRIM="sed 's/refs\/tags\///'"
TGS1="sort | uniq | tail -1"
TGS2="sort -g | uniq | tail -1"

V="${GLS} | ${TGS} | ${TFIELD} | ${RCFILT} | ${TGTRIM}"
major=$(eval "${V} | awk -F'.' '{print \$1}' | ${TGS1}")
minor=$(eval "${V} | grep ${major} | awk -F'.' '{print \$2}' | ${TGS2}")
patch=$(eval "${V} | grep ${major}.${minor} | awk -F'.' '{print \$3}' | ${TGS2}")

vers=""
[ -z "${patch}" ] && vers=$major.$minor || vers=$major.$minor.$patch

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}.zip
    sudo rm -f /tmp/${FN}
    wget -qc ${DURL}/${vers}/${FN} -O /tmp/${FN}
    sudo rm -f ${BDIR}/${APP}
    sudo mkdir /tmp/${APP}_${vers}
    sudo unzip /tmp/${FN} -d /tmp/${APP}_${vers}
    sudo install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
    sudo rm -rf /tmp/${APP}_${vers}
    sudo rm -f /tmp/${FN}
}

uptodate() {
    echo "version is current"
}

download new
# if [ -z "${APPBIN}" ]; then
#     echo "not installed"
#     download new
# else
#     APPMAJOR=$(eval $APPVER | awk -F'.' '{print $1}')
#     APPMINOR=$(eval $APPVER | awk -F'.' '{print $2}')
#     APPPATCH=$(eval $APPVER | awk -F'.' '{print $3}')
#     if [ $((${APPMAJOR})) -lt $((${major})) ]; then
#         download major
#     else
#         if [ $((${APPMINOR})) -lt $((${minor})) ]; then
#             download minor
#         else
#             if [ $((${APPPATCH})) -lt $((${patch})) ]; then
#                 download patch
#             else
#                 uptodate
#             fi
#         fi
#     fi
# fi

REPO="https://github.com/prometheus/prometheus"
DURL="https://github.com/prometheus/prometheus/releases/download"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)
TAGFILTER="refs/tags"
APP="prometheus"
APPBIN=$(which ${APP})
APPVER="${APPBIN} --version 2>&1 | grep -i ^${APP} | awk '{print \$3}'"

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
    V=$(echo $vers | sed 's/v//')
    FN=${APP}-${V}.linux-amd64.tar.gz
    sudo rm -f /tmp/${FN}
    wget -qc ${DURL}/${vers}/${FN} -O /tmp/${FN}
    sudo rm -f ${BDIR}/${APP}
    sudo rm -f ${BDIR}/promtool
    sudo mkdir /tmp/${APP}_${vers}
    sudo tar axf /tmp/${FN} -C /tmp/${APP}_${vers} --strip-components=1
    sudo install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
    sudo install /tmp/${APP}_${vers}/promtool ${BDIR}/promtool
    sudo rm -rf /tmp/${APP}_${vers}
    sudo rm -f /tmp/${FN}
}

uptodate() {
    echo "version is current"
}

if [ -z "${APPBIN}" ]; then
    echo "not installed"
    download new
else
    APPMAJOR=$(eval $APPVER | awk -F'.' '{print $1}')
    APPMINOR=$(eval $APPVER | awk -F'.' '{print $2}')
    APPPATCH=$(eval $APPVER | awk -F'.' '{print $3}')
    if [ $((${APPMAJOR})) -lt $((${major})) ]; then
        download major
    else
        if [ $((${APPMINOR})) -lt $((${minor})) ]; then
            download minor
        else
            if [ $((${APPPATCH})) -lt $((${patch})) ]; then
                download patch
            else
                uptodate
            fi
        fi
    fi
fi

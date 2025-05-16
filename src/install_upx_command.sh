APP="upx"
REPO="https://github.com/upx/upx"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

BDIR="${HOME}"/.local/bin
TMPDIR=$(mktemp -u -d)

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FVER=$(echo "${vers}" | sed 's/v//g')
    FNAME="upx-${FVER}-amd64_linux.tar.xz"
    mkdir -p "${BDIR}"
    mkdir -p "${TMPDIR}"
    wget -qO /tmp/"${FNAME}" "${REPO}"/releases/download/"${vers}"/"${FNAME}"
    tar -axf /tmp/"${FNAME}" --strip-components=1 -C "${TMPDIR}"
    cp -f "${TMPDIR}"/"${APP}" "${BDIR}"/"${APP}"
    rm -rf "/tmp/${FNAME}"
    rm -rf "${TMPDIR}"
}

if [ -z "$(which "${APP}")" ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} -V | grep -e "^upx" | awk '{print "v"$2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi
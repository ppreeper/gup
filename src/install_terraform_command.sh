APP="terraform"
REPO="https://github.com/hashicorp/terraform"
DLREPO="https://releases.hashicorp.com/terraform"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep -v -e "[rc|beta|alpha]" | sort -V | uniq | tail -1)

BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    VERS=$(echo "${vers}" | sed 's/^v//')
    FN=${APP}_${VERS}_linux_amd64.zip
    DLURL="${DLREPO}/${VERS}/${FN}"
    rm -f /tmp/"${FN}"
    wget -qc "${DLURL}" -O /tmp/"${FN}"
    sudo unzip -q /tmp/"${FN}" "${APP}" -d "${BDIR}"
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | grep ^Terraform | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi
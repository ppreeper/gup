APP="odaserver"
REPO="https://github.com/ppreeper/oda"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\/v//' | sort -V | uniq | tail -1)

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}_${vers}_amd64.deb
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/v${vers}/${FN} -O /tmp/${FN}
    sudo apt install /tmp/${FN}
    rm -f /tmp/${FN}
}

download new

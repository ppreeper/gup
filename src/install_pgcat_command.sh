APP="pgcat"
REPO="https://github.com/postgresml/pgcat"
DLREPO="https://github.com/postgresml/pgcat/archive/refs/tags"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

CDIR=${HOME}/.config/pgcat
BDIR=${HOME}/.local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${vers}.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${DLREPO}/${FN} -O /tmp/${FN}
    mkdir -p /tmp/${APP}
    tar axvf /tmp/${FN} -C /tmp/${APP} --strip-components=1
    podman run --rm -v /tmp/${APP}:/app docker.io/rust:1 bash -c "cd /app && cargo build --release"
    mkdir -p ${CDIR}
    cp /tmp/${APP}/pgcat.toml ${CDIR}/pgcat.toml
    cp /tmp/${APP}/target/release/pgcat ${BDIR}/pgcat
    rm -rf /tmp/${FN} /tmp/${APP}
}

if [ -z $(which "podman") ]; then
  echo "podman required to build ${APP}"
else
  download ${vers}
fi

APP="distrobuilder"
REPO="https://github.com/lxc/distrobuilder"

if ! command -v make >/dev/null 2>&1; then
    echo "Error: 'make' is required to build distrobuilder" >&2
    exit 1
fi

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

echo "cloning and building ${APP}..."
git clone "${REPO}" "${tmp_dir}/distrobuilder"
(cd "${tmp_dir}/distrobuilder" && make)

if [ "$(id -u)" = 0 ]; then
    BDIR="/usr/local/bin"
    sudo install -m 0755 "${tmp_dir}/distrobuilder/distrobuilder" "${BDIR}/distrobuilder"
else
    BDIR="${HOME}/.local/bin"
    mkdir -p "${BDIR}"
    install -m 0755 "${tmp_dir}/distrobuilder/distrobuilder" "${BDIR}/distrobuilder"
fi
echo "installed ${APP} to ${BDIR}/distrobuilder"

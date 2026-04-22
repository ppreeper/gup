TMP_WORK=$(gup_mktemp_dir)
trap 'rm -rf "${TMP_WORK}"' RETURN

REPO="https://github.com/lxc/distrobuilder"
git clone "${REPO}" "${TMP_WORK}/distrobuilder"
cd "${TMP_WORK}/distrobuilder" && make

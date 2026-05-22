set -euo pipefail

APP="trivy"
REPO="aquasecurity/trivy"
gup_fetch_release "${REPO}" 'contains("Linux-64bit.tar.gz")'

download() {
	echo "download $1 version"
	echo "installing ${GUP_REL_VERSION}"

	local tmp_dir
	tmp_dir=$(gup_mktemp_dir)
	trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

	gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
	tar axf "${tmp_dir}/${GUP_REL_FN}" -C "${tmp_dir}" "${APP}"
	_gup_install_binary "${tmp_dir}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
	download new
else
	APPVER=$($(command -v "${APP}") --version 2>&1 | grep -oP 'Version:\s*\K[0-9.]+' | head -1)
	if [ "${APPVER}" = "${GUP_REL_VERSION#v}" ]; then
		echo "${APP} version is current"
	else
		download "${GUP_REL_VERSION}"
	fi
fi

set -eu

APP="hugo"
REPO="gohugoio/hugo"
GUP_REL_VERSION=$(gup_get_latest_release "${REPO}")
major=$(printf '%s' "${GUP_REL_VERSION}" | sed 's/^v//' | cut -d. -f1)

# Module path major suffix must match the release major (scc is currently v4).
case "${major}" in
    ''|*[!0-9]*) module="github.com/${REPO}/v4" ;;
    0|1) module="github.com/${REPO}" ;;
    *) module="github.com/${REPO}/v${major}" ;;
esac

APPVER=$($(command -v "${APP}") version 2>&1 | awk '{print $2}' | awk -F'+' '{print $1}')
if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
    echo "${APP} version is current"
else
    gup_ensure_go
    CGO_ENABLED=0 go install -tags withdeploy "${module}@${GUP_REL_VERSION}"
fi

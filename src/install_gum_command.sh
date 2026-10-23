set -eu

APP="gum"
REPO="charmbracelet/gum"
vers=$(gup_get_latest_release "${REPO}")
major=$(printf '%s' "${vers}" | sed 's/^v//' | cut -d. -f1)

# v2+ uses the charm.land vanity module path; v1 lived under github.com.
case "${major}" in
    ''|*[!0-9]*) module="charm.land/${APP}/v2" ;;
    0|1) module="github.com/${REPO}" ;;
    *) module="charm.land/${APP}/v${major}" ;;
esac

gup_ensure_go
go install "${module}@${vers}"
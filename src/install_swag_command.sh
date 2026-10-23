set -eu

APP="swag"
REPO="swaggo/swag"
vers=$(gup_get_latest_release "${REPO}")
major=$(printf '%s' "${vers}" | sed 's/^v//' | cut -d. -f1)

# Module path major suffix must match the release major (swag is currently v2).
case "${major}" in
    ''|*[!0-9]*) module="github.com/${REPO}/v2" ;;
    0|1) module="github.com/${REPO}" ;;
    *) module="github.com/${REPO}/v${major}" ;;
esac

gup_ensure_go
go install "${module}/cmd/swag@${vers}"
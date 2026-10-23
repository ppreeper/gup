set -eu

APP="rusq"
REPO="ppreeper/rusq"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/${APP}@"${vers}"

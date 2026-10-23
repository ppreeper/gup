set -eu

APP="dlv"
REPO="go-delve/delve"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/dlv@"${vers}"

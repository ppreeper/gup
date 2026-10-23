set -eu

APP="xcaddy"
REPO="caddyserver/xcaddy"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/xcaddy@"${vers}"

set -euo pipefail

APP="goose"
REPO="pressly/goose"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/pressly/goose/v3/cmd/goose@"${vers}"
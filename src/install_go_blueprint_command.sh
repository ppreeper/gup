set -euo pipefail

APP="go-blueprint"
REPO="melkeydev/go-blueprint"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/melkeydev/go-blueprint@"${vers}"
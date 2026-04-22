set -euo pipefail

APP="gdu"
REPO="dundee/gdu"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/dundee/gdu/v5/cmd/gdu@"${vers}"
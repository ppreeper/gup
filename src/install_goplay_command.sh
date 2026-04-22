set -euo pipefail

APP="goplay"
REPO="haya14busa/goplay"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/haya14busa/goplay/cmd/goplay@"${vers}"

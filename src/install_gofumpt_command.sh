set -euo pipefail

APP="gofumpt"
REPO="mvdan/gofumpt"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install mvdan.cc/gofumpt@"${vers}"
set -euo pipefail

APP="s5cmd"
REPO="peak/s5cmd"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/peak/s5cmd/v2@"${vers}"

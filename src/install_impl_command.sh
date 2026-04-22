set -euo pipefail

APP="impl"
REPO="josharian/impl"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/josharian/impl@"${vers}"

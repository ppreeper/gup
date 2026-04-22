set -euo pipefail

APP="scc"
REPO="boyter/scc"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/boyter/scc/v3@"${vers}"
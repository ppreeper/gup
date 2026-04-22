set -euo pipefail

APP="goimports"
REPO="golang/tools"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install golang.org/x/tools/cmd/goimports@"${vers}"
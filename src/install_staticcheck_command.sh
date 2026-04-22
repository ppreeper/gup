set -euo pipefail

APP="staticcheck"
REPO="dominikh/go-tools"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install honnef.co/go/tools/cmd/staticcheck@"${vers}"

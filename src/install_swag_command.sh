set -euo pipefail

APP="swag"
REPO="swaggo/swag"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/swaggo/swag/cmd/swag@"${vers}"
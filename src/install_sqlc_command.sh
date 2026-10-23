set -eu

APP="sqlc"
REPO="sqlc-dev/sqlc"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/sqlc@"${vers}"
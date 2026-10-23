set -eu

APP="templ"
REPO="a-h/templ"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/templ@"${vers}"

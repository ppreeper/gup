set -eu

APP="ruxx"
REPO="ppreeper/ruxx"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/${APP}@"${vers}"

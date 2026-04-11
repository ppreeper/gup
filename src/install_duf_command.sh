APP="duf"
REPO="muesli/duf"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/muesli/duf@${vers}
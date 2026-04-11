APP="muffet"
REPO="raviqqe/muffet"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/raviqqe/muffet/v2@${vers}
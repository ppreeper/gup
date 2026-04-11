APP="gowebly"
REPO="gowebly/gowebly"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/gowebly/gowebly/v2@${vers}
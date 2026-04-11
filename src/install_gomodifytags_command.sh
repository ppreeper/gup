APP="gomodifytags"
REPO="fatih/gomodifytags"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/fatih/gomodifytags@${vers}

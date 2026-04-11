APP="golangci-lint"
REPO="golangci/golangci-lint"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${vers}
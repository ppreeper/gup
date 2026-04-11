gup_ensure_go() {
    local missing_deps=()
    for dep in go; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo $dep
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing go: please install Go \`gup install go\`" >&2
        exit 1
    fi
}

# download using curl or wget
gup_download() {
    local url="$1"
    local output="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$output" "$url"
    else
        wget -qO "$output" "$url"
    fi
}

# get the latest release tag from GitHub API
gup_get_latest_release() {
    local repo="$1"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    wget -qO- "${api_url}" | jq -r .tag_name
    # wget -qO- "${api_url}" | jq .tag_name | tr -d '"'
}

gup_get_latest_dl() {
    local repo="$1"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    wget -qO- "${api_url}" | jq -r .tag_name
    # wget -qO- "${api_url}" | jq .tag_name | tr -d '"'
}
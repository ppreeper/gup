# default prefix (can be overridden)
: "${GUP_PREFIX:=${HOME}/.local}"

gup_ensure_deps() {
    local missing_deps=()
    for dep in git wget jq tar unzip; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo $dep
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing dependencies: ${missing_deps[*]}" >&2
        exit 1
    fi
}
gup_ensure_deps
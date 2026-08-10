#!/usr/bin/env bash
# open_github.sh — open the GitHub page for the current project's origin remote

set -euo pipefail

# make sure we're inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository." >&2
    exit 1
fi

remote_url=$(git config --get remote.origin.url 2>/dev/null || true)

if [[ -z "$remote_url" ]]; then
    echo "No 'origin' remote found." >&2
    exit 1
fi

# normalize remote url -> https://github.com/user/repo
# handles:
#   git@github.com:user/repo.git
#   ssh://git@github.com/user/repo.git
#   https://github.com/user/repo.git
#   https://github.com/user/repo
url="$remote_url"

url="${url#ssh://}"
url="${url/git@github.com:/github.com/}"
url="${url#https://}"
url="${url#http://}"
url="${url%.git}"

github_url="https://${url}"

# get current branch, so we can jump straight to it (optional but handy)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [[ -n "$branch" && "$branch" != "HEAD" && "$branch" != "main" && "$branch" != "master" ]]; then
    github_url="${github_url}/tree/${branch}"
fi

echo "Opening: $github_url"

# open with whatever's available on the system
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$github_url" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
    open "$github_url"
elif command -v wslview >/dev/null 2>&1; then
    wslview "$github_url"
else
    echo "Could not detect a way to open a browser. URL: $github_url" >&2
    exit 1
fi

#!/bin/bash
# Prepares a release of RoundedCorners.
# Usage: scripts/release.sh 0.2.0
set -euo pipefail
cd "$(dirname "$0")/.."

fail() {
    echo "Error: $*" >&2
    exit 1
}

VERSION="${1:-}"
[[ -n "$VERSION" ]] || fail "sebutkan versinya, misalnya: scripts/release.sh 0.2.0"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "versi harus berbentuk angka.angka.angka, misalnya 0.2.0"
TAG="v$VERSION"

for tool in git xcodegen xcodebuild gh; do
    command -v "$tool" >/dev/null 2>&1 || fail "$tool tidak ditemukan."
done

echo "Memeriksa sebelum rilis $TAG..."

[[ "$(git branch --show-current)" == "main" ]] || fail "rilis hanya dari branch main."
[[ -z "$(git status --porcelain)" ]] || fail "masih ada perubahan yang belum di-commit."

git fetch --quiet --tags origin main
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] \
    || fail "main di komputer ini belum sama dengan GitHub. Push atau pull dulu."

PROJECT_VERSION=$(sed -nE 's/^ *CFBundleShortVersionString: *"([^"]+)".*/\1/p' project.yml)
[[ "$PROJECT_VERSION" == "$VERSION" ]] \
    || fail "versi di project.yml masih $PROJECT_VERSION, bukan $VERSION."

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    fail "tag $TAG sudah ada."
fi

grep -qx "## $VERSION" CHANGELOG.md || fail "CHANGELOG.md belum punya bagian \"## $VERSION\"."

gh auth status >/dev/null 2>&1 || fail "gh belum login. Jalankan: gh auth login"

echo "Semua pemeriksaan lolos."

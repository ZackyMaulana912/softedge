#!/bin/bash
# Runs the automated tests. They never launch the app or touch its settings.
set -euo pipefail
cd "$(dirname "$0")/.."

for tool in xcodegen xcodebuild; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Error: $tool tidak ditemukan." >&2
        exit 1
    fi
done

mkdir -p build
LOG="build/test.log"

xcodegen generate --quiet
if xcodebuild test -project RoundedCorners.xcodeproj -scheme RoundedCorners \
    -destination 'platform=macOS' -derivedDataPath build > "$LOG" 2>&1; then
    grep -E "Test run with" "$LOG" | tail -1 || true
    echo "Semua tes lolos."
else
    grep -E "error:|recorded an issue|Test run with" "$LOG" | head -40 >&2 || true
    echo "Tes gagal. Log lengkap: $LOG" >&2
    exit 1
fi

#!/bin/sh
# Installs or updates Nest Watcher on a Mac, from the latest public release:
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/install.sh | OPENROUTER_API_KEY=sk-or-... sh
# The key is asked for on the first install only. To remove: quit the app, then
#   rm -rf "/Applications/Nest Watcher.app" ~/.nest/watcher
set -eu

releases=https://github.com/BlueprintAIx/nest-public/releases/latest/download
app="/Applications/Nest Watcher.app"
data="$HOME/.nest/watcher"

fail() { echo "install: $1" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || fail "Nest Watcher runs on macOS only"
# ponytail: Apple silicon only; an Intel build needs @parcel/watcher-darwin-x64 bundled
[ "$(uname -m)" = arm64 ] || fail "this build is for Apple silicon Macs"

mkdir -p "$data"
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    # readable by this user only
    (umask 077; printf 'MAIN_VITE_OPENROUTER_API_KEY=%s\n' "$OPENROUTER_API_KEY" > "$data/.env")
elif [ ! -f "$data/.env" ]; then
    fail "run it with the key you were given: ... | OPENROUTER_API_KEY=sk-or-... sh"
fi

download=$(mktemp -d)
trap 'rm -rf "$download"' EXIT
echo "Downloading Nest Watcher..."
curl -fL --progress-bar "$releases/nest-watcher-arm64.zip" -o "$download/app.zip"

pkill -x "Nest Watcher" 2>/dev/null && sleep 2 || true
rm -rf "$app"
ditto -xk "$download/app.zip" /Applications
open "$app"
echo "Nest Watcher is installed and running: look for it in your menu bar."

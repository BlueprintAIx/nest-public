#!/bin/sh
# Installs or updates Nest Watcher on a Mac, from the latest public release:
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/install.sh | OPENROUTER_API_KEY=sk-or-... sh
# The key is asked for on the first install only. To remove: quit the app, then
#   rm -rf "/Applications/Nest Watcher.app" ~/.nest/watcher
set -eu

releases=https://github.com/BlueprintAIx/nest-public/releases/latest/download
app="/Applications/Nest Watcher.app"
data="$HOME/.nest/watcher"

fail() { printf '\n  %s\n\n' "$1" >&2; exit 1; }
done_() { printf '  \033[38;5;69m✓\033[0m %s\n' "$1"; }

# one line that redraws itself: a bar, the share done, and megabytes; `$1` of `$2` bytes
bar() {
    filled=$(($1 * 24 / $2))
    printf '\r  Downloading  \033[38;5;69m'
    at=0
    while [ $at -lt 24 ]; do
        [ $at -eq $filled ] && printf '\033[38;5;240m'
        printf '━'
        at=$((at + 1))
    done
    printf '\033[0m  %3d%%  %d of %d MB ' $(($1 * 100 / $2)) $(($1 / 1048576)) $(($2 / 1048576))
}

[ "$(uname -s)" = Darwin ] || fail "Nest Watcher runs on macOS only."
# ponytail: Apple silicon only; an Intel build needs @parcel/watcher-darwin-x64 bundled
[ "$(uname -m)" = arm64 ] || fail "This build is for Apple silicon Macs."

printf '\n  \033[1mNest Watcher\033[0m\n\n'
mkdir -p "$data"
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    # readable by this user only
    (umask 077; printf 'MAIN_VITE_OPENROUTER_API_KEY=%s\n' "$OPENROUTER_API_KEY" > "$data/.env")
elif [ ! -f "$data/.env" ]; then
    fail "Run it with the key you were given: ... | OPENROUTER_API_KEY=sk-or-... sh"
fi

download=$(mktemp -d)
trap 'rm -rf "$download"' EXIT
size=$(curl -fsSLI "$releases/nest-watcher-arm64.zip" | awk 'tolower($1) == "content-length:" { size = $2 } END { print size + 0 }')
: > "$download/app.zip"
curl -fsSL "$releases/nest-watcher-arm64.zip" -o "$download/app.zip" &
fetch=$!
# drawn only for a person at a terminal, and only when GitHub said how big the file is
while [ -t 1 ] && [ "$size" -gt 0 ] && kill -0 $fetch 2>/dev/null; do
    bar $(($(wc -c < "$download/app.zip"))) "$size"
    sleep 0.2
done
wait $fetch || fail "The download failed. Check your connection and run the line again."
[ -t 1 ] && printf '\r\033[K'
done_ "Downloaded"

pkill -x "Nest Watcher" 2>/dev/null && sleep 2 || true
rm -rf "$app"
ditto -xk "$download/app.zip" /Applications
done_ "Installed in Applications"
open "$app"
done_ "Running: look for it in your menu bar"
echo

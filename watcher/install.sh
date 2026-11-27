#!/bin/sh
# Installs or updates Corefoil on a Mac, from the latest public release:
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/install.sh | sh
# The app asks the user to sign in to Corefoil for the model's key. uninstall.sh, beside this file, removes it.
set -eu

releases=https://github.com/BlueprintAIx/nest-public/releases/latest/download
app="/Applications/Corefoil.app"
# the app was called Nest Watcher until 0.1.13; an update puts Corefoil in its place
old="/Applications/Nest Watcher.app"

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

[ "$(uname -s)" = Darwin ] || fail "Corefoil runs on macOS only."
# the chip, not uname -m, which says x86_64 in a terminal running under Rosetta
[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = 1 ] && arch=arm64 || arch=x64

printf '\n  \033[1mCorefoil\033[0m\n\n'

download=$(mktemp -d)
trap 'rm -rf "$download"' EXIT
size=$(curl -fsSLI "$releases/nest-watcher-$arch.zip" | awk 'tolower($1) == "content-length:" { size = $2 } END { print size + 0 }')
: > "$download/app.zip"
curl -fsSL "$releases/nest-watcher-$arch.zip" -o "$download/app.zip" &
fetch=$!
# drawn only for a person at a terminal, and only when GitHub said how big the file is
while [ -t 1 ] && [ "$size" -gt 0 ] && kill -0 $fetch 2>/dev/null; do
    bar $(($(wc -c < "$download/app.zip"))) "$size"
    sleep 0.2
done
wait $fetch || fail "The download failed. Check your connection and run the line again."
[ -t 1 ] && printf '\r\033[K'
done_ "Downloaded"

pkill -x 'Corefoil|Nest Watcher' 2>/dev/null && sleep 2 || true
rm -rf "$app" "$old"
ditto -xk "$download/app.zip" /Applications
done_ "Installed version $(defaults read "$app/Contents/Info" CFBundleShortVersionString) in Applications"
open "$app"
done_ "Running: look for it in your menu bar"
echo

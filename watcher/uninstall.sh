#!/bin/sh
# Removes Nest Watcher from a Mac: the app, and what it kept for this user (the key, the connection, what it has seen).
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/uninstall.sh | sh
# Nothing in Google Drive is touched.
set -eu

app="/Applications/Nest Watcher.app"
data="$HOME/.nest/watcher"

done_() { printf '  \033[38;5;69m✓\033[0m %s\n' "$1"; }

printf '\n  \033[1mNest Watcher\033[0m\n\n'
pkill -x "Nest Watcher" 2>/dev/null && sleep 2 || true
rm -rf "$app"
done_ "Removed from Applications"
rm -rf "$data"
done_ "Removed its data on this Mac"
printf '\n  Your insights in Google Drive are untouched. To withdraw its access to Drive,\n  remove it at https://myaccount.google.com/connections\n\n'

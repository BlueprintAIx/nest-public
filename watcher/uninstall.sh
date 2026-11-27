#!/bin/sh
# Removes Corefoil (formerly Nest Watcher) from a Mac: the app and what it kept for this user (the key, the connection, what it has seen).
# What it added to Claude and ChatGPT stays, for the user to remove there.
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/uninstall.sh | sh
# Nothing in Google Drive is touched.
set -eu

app="/Applications/Corefoil.app"
old="/Applications/Nest Watcher.app"
data="$HOME/.nest/watcher"
inbox="$HOME/.nest/inbox"
# what macOS and Electron keep for the app beside its data, named after its bundle id and its package name, watcher
id=com.corefoil.nest-watcher

done_() { printf '  \033[38;5;69m✓\033[0m %s\n' "$1"; }

printf '\n  \033[1mCorefoil\033[0m\n\n'
pkill -x 'Corefoil|Nest Watcher' 2>/dev/null && sleep 2 || true
rm -rf "$app" "$old"
done_ "Removed from Applications"
rm -rf "$data" "$inbox" "$HOME/Library/Application Support/watcher" "$HOME/Library/Caches/$id" "$HOME/Library/Caches/$id.ShipIt" "$HOME/Library/Caches/watcher-updater" "$HOME/Library/HTTPStorages/$id"
# Electron's data under the names the app had before 0.1.10 (nest-watcher) and in its development (@nest-watcher), and the updater's preferences for this Mac
rm -rf "$HOME/Library/Application Support/nest-watcher" "$HOME/Library/Application Support/@nest-watcher" "$HOME/Library/Preferences/ByHost/$id.ShipIt."*.plist
# what Finder leaves in a folder it showed does not keep it
rm -f "$HOME/.nest/.DS_Store"
rmdir "$HOME/.nest" 2>/dev/null || true
# through defaults, as the preferences daemon would write a removed file back
defaults delete "$id" >/dev/null 2>&1 || true
# the Keychain item earlier versions encrypted its keys and tokens with; nothing is left that it could open
security delete-generic-password -s "watcher Safe Storage" -a "watcher Key" >/dev/null 2>&1 || true
done_ "Removed its data on this Mac"
printf '\n  Your insights in Google Drive are untouched. To withdraw its access to Drive,\n  remove it at https://myaccount.google.com/connections\n'
printf '  In Claude and ChatGPT, remove the watcher-notes skill under Settings if you added it.\n\n'

#!/bin/sh
# Removes Corefoil (formerly Nest Watcher) from a Mac: the app, what it kept for this user (the key, the connection, what it has seen), and what it added to AI apps.
#   curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/uninstall.sh | sh
# Nothing in Google Drive is touched.
set -eu

app="/Applications/Corefoil.app"
old="/Applications/Nest Watcher.app"
data="$HOME/.nest/watcher"
inbox="$HOME/.nest/inbox"
chatgpt="$HOME/.codex"
mark="# Nest Watcher: where ChatGPT leaves notes for it"

done_() { printf '  \033[38;5;69m✓\033[0m %s\n' "$1"; }

printf '\n  \033[1mCorefoil\033[0m\n\n'
pkill -x 'Corefoil|Nest Watcher' 2>/dev/null && sleep 2 || true
rm -rf "$app" "$old"
done_ "Removed from Applications"
rm -rf "$data" "$inbox"
done_ "Removed its data on this Mac"
rm -rf "$chatgpt/skills/watcher-notes"
if [ -f "$chatgpt/config.toml" ]; then
    MARK="$mark" perl -0pi -e 's/\n?\Q$ENV{MARK}\E\n\[sandbox_workspace_write\]\nwritable_roots = [^\n]*\n//' "$chatgpt/config.toml"
fi
done_ "Removed from ChatGPT"
printf '\n  Your insights in Google Drive are untouched. To withdraw its access to Drive,\n  remove it at https://myaccount.google.com/connections\n'
printf '  In Claude, remove watcher-notes under Settings → Plugins.\n\n'

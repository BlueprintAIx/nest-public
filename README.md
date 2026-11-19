# Nest: public downloads

## Nest Watcher

A Mac menu bar app that notices work documents and meetings worth keeping, summarises them, and shares the ones you approve.

Requires an Apple silicon Mac. Install or update by pasting this into Terminal, with the key you were given:

```sh
curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/install.sh | OPENROUTER_API_KEY=sk-or-... sh
```

The key is only needed the first time. To update later, run the same line without it:

```sh
curl -fsSL https://raw.githubusercontent.com/BlueprintAIx/nest-public/main/watcher/install.sh | sh
```

To remove it, quit the app from its menu bar icon, then:

```sh
rm -rf "/Applications/Nest Watcher.app" ~/.nest/watcher
```

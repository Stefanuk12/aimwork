stylua src
selene src
:: luau-lsp analyze --settings .vscode/settings.json src
darklua process src/init.luau dist.luau -c .darklua.json
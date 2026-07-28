# cmux terminal theme

A terminal-native [cmux](https://cmux.com) setup — [Tokyo Night](https://github.com/folke/tokyonight.nvim), seamless, mono everywhere. The goal: make cmux read as a real terminal instead of native macOS chrome, with the sidebar, tabs, and terminal all sharing one flat, opaque palette.

Everything here is **runtime config** — no build, no fork. Drop these files into `~/.config` and `cmux reload-config`.

## What's in it

| File | What it does |
|---|---|
| `cmux/cmux.json` | App appearance, sidebar tint (matches the terminal bg to kill the seam), Tokyo Night workspace colors, and per-state **tab bar styling**. |
| `cmux/sidebars/terminal.swift` | A custom sidebar (cmux beta feature) that renders the workspace list like a shell prompt. Uses **adaptive color tokens** (`primary`/`secondary`/`accent`…) so it follows the light/dark toggle automatically. |
| `ghostty/config` | Terminal theme (TokyoNight / TokyoNight Day via `cmux themes set`), SF Mono, solid opaque background, block cursor. |

## Install

```bash
git clone https://github.com/dprovder/cmux-terminal-theme.git
cd cmux-terminal-theme
./install.sh          # backs up any existing config, then copies these in
cmux reload-config    # hot-reloads both cmux.json and ghostty config
```

The installer timestamps and backs up anything it would overwrite (`*.bak-<date>`), so it's safe to run over an existing setup.

To pair the terminal light/dark themes with the appearance toggle:

```bash
cmux themes set --light "TokyoNight Day" --dark TokyoNight
```

## Notes

- **Custom sidebar** is a cmux beta feature. It *replaces* the native sidebar, so it doesn't compose with **minimal mode** (minimal mode draws native controls into the sidebar, which the custom layer can't render). Use **standard** presentation mode with this sidebar, or the native sidebar if you want minimal mode.
- The sidebar follows light/dark because it uses adaptive DSL color tokens, not frozen hex. The `tabBar*` keys in `cmux.json`, however, are flat hex and stay pinned to one palette.
- The per-state **surface tab bar styling** (`tabBarActiveBackground`, `tabBarActiveIndicatorColor`, etc.) comes from an upstream contribution: cmux [#8903](https://github.com/manaflow-ai/cmux/pull/8903) / issue [#7458](https://github.com/manaflow-ai/cmux/issues/7458). Released cmux ignores those keys until it ships.

## License

MIT — do whatever you like with it.

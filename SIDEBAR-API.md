# cmux custom sidebar — full featureset reference

Everything the interpreted custom-sidebar DSL (`~/.config/cmux/sidebars/*.swift`)
exposes. Config-only: no build, no fork. Hot-reloads on save. Re-evaluates ~1×/sec
so data stays live. Authoritative source: `docs/custom-sidebars.md` in the cmux repo.

---

## Live data you can bind to (read-only)

### `workspaces` — array, one per workspace
**Always present:**
| Field | Type | Notes |
|---|---|---|
| `id` | String | pass to `workspace.select` |
| `title` | String | |
| `selected` | Bool | is it the active workspace |
| `pinned` | Bool | |
| `index` | Int | order |
| `directory` | String | working dir |
| `ports` | [Int] | **detected listening ports (running servers)** |
| `portCount` | Int | |
| `unread` | Int | unread notifications |
| `tabs` | [Tab] | see below |
| `tabCount` | Int | |

**Present only when the workspace has them** (guard with `if let` / ternary):
| Field | Shape |
|---|---|
| `description` | String |
| `color` | hex String |
| `branch` | String (git) |
| `dirty` | Bool (git uncommitted) |
| `pr` | `{ number, label, url, status: open\|merged\|closed, stale, branch }` — first PR |
| `prs` | array of the above — every PR cmux knows |
| `progress` | `{ value: 0..1, label }` |
| `latestMessage` | String — last agent message |
| `latestPrompt` | String — last submitted prompt |
| `latestAt` | epoch Int |
| `remote` | `{ target, state, connected }` |

### `tabs` (per workspace) — array of surfaces
Always: `id`, `title`, `focused` (Bool), `pinned` (Bool).
When available: `directory`, `branch` + `dirty`, `ports` ([Int]).

### Top-level
- `workspaceCount` — Int
- `selectedTitle` — active workspace title · `selectedId` — its id
- `unreadTotal` — total unread notifications
- `clock` — `{ time "HH:mm:ss", hour, minute, second, weekday, epoch }`

> ⚠️ **Not exposed:** the formal **workspace-group** structure (which workspace is in
> which group). You can *trigger* `workspace.group.*` actions, but can't *read* group
> membership to render it. Group by live *signals* instead (status/branch/ports/PR),
> like `status-board.swift` does.

---

## Views

**Containers:** `VStack` `HStack` `ZStack` `LazyVStack` `LazyHStack` `Group`
`EmptyView()` `List{}` `Section("H"){}` `Grid{GridRow{}}` `LazyVGrid` `LazyHGrid`
`ViewThatFits{}` `ScrollView{}` (`.horizontal` for a strip) `HSplitView{a;b}`
(two resizable persisted columns).

**Content:** `Text` `Label("T", systemImage:)` `Image(systemName:)` (SF Symbols)
`Button` `Menu("T"){}` `ProgressView(value:)` `Gauge(value:)` `Spacer` `Divider`
`AnyView`.

**Shapes:** `Rectangle` `RoundedRectangle(cornerRadius:)` `UnevenRoundedRectangle`
`Capsule` `Circle` `Ellipse` — `.fill` `.stroke("#hex", lineWidth:)` `.trim(from:to:)`.

**Reorder:** `Reorderable(data, move: "workspace.reorder") { item in <row> }` — the
supported way to make a list drag-and-drop (persists order). Sends `workspace_id` + `index`.

---

## Modifiers

**Text:** `.font(.title2|.headline|.caption|.system(size:design:))` `.bold()` `.italic()`
`.fontWeight()` `.fontDesign(.monospaced)` `.monospaced()` `.monospacedDigit()`
`.lineLimit()` `.truncationMode()` `.multilineTextAlignment()` `.textCase()`
`.strikethrough()` `.underline()`.

**Color:** `.foregroundColor`/`.foregroundStyle`/`.fill`/`.tint` take a hex `"#FF8800"`
**or an adaptive token** — this is what makes the sidebar follow light/dark:

| Token | Meaning |
|---|---|
| `primary` `secondary` `tertiary` `quaternary` | text shades, auto light/dark |
| `accent` | app/theme accent |
| `red orange yellow green mint teal cyan blue indigo purple pink brown gray white black clear` | system colors, appearance-aware |

**Layout:** `.padding` `.frame(width:height:maxWidth:.infinity, alignment:)` `.fixedSize`
`.layoutPriority` `.offset` `.zIndex` `.aspectRatio` `.scaledToFit/Fill`.

**Decoration:** `.background("#hex")` or `.background{}` · `.overlay(alignment:){}` `.mask{}`
`.safeAreaInset(edge:){}` `.cornerRadius` `.clipShape` `.clipped` `.shadow` `.border`
`.blur` `.opacity` `.brightness/.contrast/.saturation/.grayscale` `.rotationEffect`
`.scaleEffect` `.redacted`.

**SF Symbols:** `.imageScale` `.symbolRenderingMode` `.symbolVariant`.

**Interaction:** `.onTapGesture{}` `.contextMenu{}` `.help("tip")` `.disabled(cond)`
`.accessibilityLabel`.

---

## Language subset

`let` bindings; user `func` helpers (value + view-returning); `for x in array` /
`for i in 0..<n`; `ForEach(array){}`, `ForEach(array.indices){}`,
`ForEach(Array(array.enumerated()), id: \.offset){}`; `if/else`; ternary `a ? b : c`;
interpolation `"\(x)"`; `+ - * / %` (safe `/0`); comparisons; `&& || !`; ranges;
array/dict literals; member/subscript access.

**Array:** `.filter .map .flatMap .reduce .sorted{ $0 > $1 } .first .last .contains
.count .reversed .prefix(n) .suffix(n) .dropFirst .dropLast .enumerated .indices`.
**String:** `.hasPrefix .hasSuffix .contains .uppercased .lowercased .split(separator:)`.
**Number:** `.formatted(.currency(code:)) / .percent / .notation(.compactName)`.
**Builtins:** `min max abs Int() Double() String()`.

---

## Actions (run real cmux commands on tap)

`cmux("<method>", param: value)` — dispatches through the same surface as the `cmux`
CLI. Common:

| Method | Params | Does |
|---|---|---|
| `workspace.select` | `workspace_id` | focus a workspace |
| `workspace.reorder` | `workspace_id`, `index` | move + persist |
| `workspace.create` | — | new workspace |
| `workspace.next` / `workspace.previous` / `workspace.last` | — | cycle |
| `surface.focus` | `surface_id` | focus a tab |
| `notification.jump_to_unread` | — | jump to next unread |

Full list: `cmux capabilities` (JSON `methods`) or `cmux docs api`.

---

## Not yet supported

`@State` and controls needing it (`TextField` `Toggle` `Slider` `Picker`); `switch`;
custom `struct`/`View` defs; gradients; navigation (`sheet`/`popover`/`NavigationStack`);
`.keyboardShortcut`; `AsyncImage`/`.resizable`. Unsupported syntax is skipped, never crashes.

---

## The three ways to customize the sidebar

| Lane | What | Build? | Power |
|---|---|---|---|
| **Config theming** | `cmux.json` `sidebarAppearance` + `workspaceColors` — tint/colors of the **native** sidebar | none | low, but composes with everything (incl. minimal mode) |
| **Custom sidebar** (this doc) | interpreted `.swift`/`.json` that **replaces** the native sidebar | none (hot-reload) | high layout freedom; can't render native chrome (minimal-mode controls) |
| **Sidebar extension** | a signed **ExtensionKit app extension** (separate app w/ bundle id) that provides a sidebar via typed host API + permission grants | **yes — Xcode + signing** | highest: real SwiftUI, async host calls, permission scopes; distributable to others |

See `Examples/SampleSidebarExtensionApp/` in the cmux repo for the extension reference.

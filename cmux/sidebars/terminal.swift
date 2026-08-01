// terminal.swift — a terminal-styled cmux sidebar that FOLLOWS the app's
// light/dark appearance (adaptive DSL tokens, no hardcoded hex). FLAT list: each
// workspace is a single-button row; the selected workspace's tabs (surfaces) are
// their own single-button rows right below it, indented. Tapping a workspace
// selects it; tapping a tab focuses that exact surface. Single-button rows stay
// compact (a multi-child VStack row would stretch — see SIDEBAR-API.md), which is
// why tabs are sibling rows, not nested children.
//   preview:  cmux sidebar select terminal      edit-in-pane:  cmux sidebar open terminal
// NOTE: use STANDARD presentation mode. Trade-off: no drag-reorder (a flat loop,
// not Reorderable) in exchange for per-surface clickability.

VStack(alignment: .leading, spacing: 0) {

    // ── prompt-style header ─────────────────────────────────────────────
    HStack(spacing: 6) {
        Text("➜").foregroundColor("green").fontDesign(.monospaced).bold()
        Text("cmux").foregroundColor("accent").fontDesign(.monospaced).bold()
        Text("workspaces").foregroundColor("secondary").fontDesign(.monospaced)
        Spacer()
        Text(clock.time)
            .foregroundColor("secondary").fontDesign(.monospaced).monospacedDigit().font(.caption)
    }
    .padding(10)

    Rectangle().fill("quaternary").frame(height: 1).frame(maxWidth: .infinity)

    // ── flat list: workspace rows + (for the selected one) tab rows ─────
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 8) {
            for w in workspaces {

                // workspace row — single button → select
                Button(action: { cmux("workspace.select", workspace_id: w.id) }) {
                    HStack(spacing: 8) {
                        Text(w.unread > 0 ? "●" : (w.selected ? "▸" : "○"))
                            .font(.caption).fontDesign(.monospaced)
                            .foregroundColor(w.unread > 0 ? "red" : (w.selected ? "green" : "tertiary"))

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(w.title)
                                    .foregroundColor(w.selected ? "primary" : "secondary")
                                    .fontDesign(.monospaced).lineLimit(1)
                                if let pr = w.pr {
                                    Text("⇅#\(pr.number)")
                                        .foregroundColor(pr.status == "merged" ? "purple" : (pr.status == "closed" ? "red" : "green"))
                                        .fontDesign(.monospaced).font(.caption2)
                                }
                            }
                            if let d = w.description {
                                Text(d).foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
                            }
                            HStack(spacing: 8) {
                                if let b = w.branch {
                                    HStack(spacing: 3) {
                                        Text("⎇").foregroundColor("cyan").font(.caption)
                                        Text(b).foregroundColor("secondary").fontDesign(.monospaced).font(.caption).lineLimit(1)
                                        if w.dirty { Text("✳").foregroundColor("orange").font(.caption) }
                                    }
                                }
                                if let r = w.remote {
                                    Text("⇄\(r.target)")
                                        .foregroundColor(r.connected ? "green" : "tertiary")
                                        .fontDesign(.monospaced).font(.caption).lineLimit(1)
                                }
                                if w.tabCount > 0 {
                                    Text("\(w.tabCount)⊞").foregroundColor("tertiary").fontDesign(.monospaced).font(.caption)
                                }
                                if let pg = w.progress {
                                    Text("\(Int(pg.value * 100))%").foregroundColor("accent").fontDesign(.monospaced).font(.caption)
                                }
                            }
                        }

                        Spacer()

                        if w.unread > 0 {
                            Text("\(w.unread)")
                                .foregroundColor("white").fontDesign(.monospaced).font(.caption).bold()
                                .padding(4).background("red").cornerRadius(6)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .background(w.selected ? "quaternary" : "clear")
                    .overlay(alignment: .leading) {
                        Rectangle().fill(w.selected ? "accent" : "clear").frame(width: 3)
                    }
                    .cornerRadius(6)
                }

                // tab rows (selected workspace only) — each a single button → focus.
                // Sibling rows in the flat list, NOT nested, so they stay compact.
                if w.selected {
                    for t in w.tabs.prefix(10) {
                        Button(action: { cmux("surface.focus", surface_id: t.id) }) {
                            HStack(spacing: 6) {
                                Rectangle().fill("clear").frame(width: 14, height: 10)
                                Text(t.focused ? "▸" : "·")
                                    .foregroundColor(t.focused ? "accent" : "tertiary").fontDesign(.monospaced).font(.caption)
                                Text(t.title)
                                    .foregroundColor(t.focused ? "primary" : "secondary").fontDesign(.monospaced).font(.caption).lineLimit(1)
                                for p in t.ports {
                                    Text(":\(p)").foregroundColor("green").fontDesign(.monospaced).font(.caption2)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(6)
    }

    // ── shell status-bar footer ─────────────────────────────────────────
    Rectangle().fill("quaternary").frame(height: 1).frame(maxWidth: .infinity)
    HStack(spacing: 6) {
        Text("\(workspaceCount)").foregroundColor("accent").fontDesign(.monospaced).bold()
        Text(workspaceCount == 1 ? "workspace" : "workspaces")
            .foregroundColor("secondary").fontDesign(.monospaced).font(.caption)
        Spacer()
        if unreadTotal > 0 {
            Text("● \(unreadTotal) unread").foregroundColor("red").fontDesign(.monospaced).font(.caption)
        } else {
            Text("● clear").foregroundColor("green").fontDesign(.monospaced).font(.caption)
        }
    }
    .padding(10)
}
.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

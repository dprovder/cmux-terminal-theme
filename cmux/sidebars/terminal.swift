// terminal.swift — a terminal-styled cmux sidebar that FOLLOWS the app's
// light/dark appearance (adaptive DSL tokens, no hardcoded hex). Surfaces the
// full workspace snapshot the DSL exposes: title, description, git branch/dirty,
// remote status, PR state, progress, running servers (ports), and — for the
// selected workspace — its directory and each tab (surface). Tapping a port or
// tab focuses that exact surface; tapping a row selects the workspace.
//   preview:  cmux sidebar select terminal      edit-in-pane:  cmux sidebar open terminal
// NOTE: use STANDARD presentation mode (minimal mode's native controls can't
// render inside a custom sidebar).

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

    // ── live, tappable, drag-to-reorder workspace list ──────────────────
    ScrollView {
        VStack(alignment: .leading, spacing: 1) {
            Reorderable(workspaces, move: "workspace.reorder") { w in
                VStack(alignment: .leading, spacing: 4) {

                    // main row → select the workspace
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
                                    // pull request state
                                    if let pr = w.pr {
                                        Text("⇅#\(pr.number)")
                                            .foregroundColor(pr.status == "merged" ? "purple" : (pr.status == "closed" ? "red" : "green"))
                                            .fontDesign(.monospaced).font(.caption2)
                                    }
                                }

                                // detail text (workspace description)
                                if let d = w.description {
                                    Text(d)
                                        .foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
                                }

                                // metadata — branch · dirty · remote · tabs
                                HStack(spacing: 8) {
                                    if let b = w.branch {
                                        HStack(spacing: 3) {
                                            Text("⎇").foregroundColor("cyan").font(.caption)
                                            Text(b).foregroundColor("secondary").fontDesign(.monospaced).font(.caption).lineLimit(1)
                                            if w.dirty { Text("✳").foregroundColor("orange").font(.caption) }
                                        }
                                    }
                                    if let r = w.remote {
                                        Text("⇄ \(r.target)")
                                            .foregroundColor(r.connected ? "green" : "tertiary")
                                            .fontDesign(.monospaced).font(.caption).lineLimit(1)
                                    }
                                    if w.tabCount > 0 {
                                        Text("\(w.tabCount)⊞").foregroundColor("tertiary").fontDesign(.monospaced).font(.caption)
                                    }
                                }

                                // progress (agent / task)
                                if let pg = w.progress {
                                    HStack(spacing: 6) {
                                        ProgressView(value: pg.value).frame(width: 60)
                                        Text(pg.label).foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
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
                    }

                    // running servers — chip per port, focuses the owning surface
                    if w.portCount > 0 {
                        HStack(spacing: 5) {
                            Text("◆").foregroundColor("green").font(.caption2)
                            for p in w.ports {
                                let owner = w.tabs.filter { $0.ports.contains(p) }.first
                                Button(action: {
                                    owner != nil
                                        ? cmux("surface.focus", surface_id: owner.id)
                                        : cmux("workspace.select", workspace_id: w.id)
                                }) {
                                    Text(":\(p)")
                                        .foregroundColor("green").fontDesign(.monospaced).font(.caption)
                                        .padding(.vertical, 1).padding(.horizontal, 5)
                                        .background("quaternary").cornerRadius(4)
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }

                    // expanded detail for the selected workspace: path + tabs
                    if w.selected {
                        Text(w.directory)
                            .foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2)
                            .lineLimit(1).truncationMode(.head)
                            .padding(.leading, 20)

                        for t in w.tabs.prefix(12) {
                            Button(action: { cmux("surface.focus", surface_id: t.id) }) {
                                HStack(spacing: 6) {
                                    Text(t.focused ? "▸" : "·")
                                        .foregroundColor(t.focused ? "accent" : "tertiary").fontDesign(.monospaced).font(.caption2)
                                    Text(t.title)
                                        .foregroundColor(t.focused ? "primary" : "secondary").fontDesign(.monospaced).font(.caption).lineLimit(1)
                                    if let tb = t.branch {
                                        Text("⎇\(tb)").foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 1)
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(w.selected ? "quaternary" : "clear")
                .overlay(alignment: .leading) {
                    Rectangle().fill(w.selected ? "accent" : "clear").frame(width: 3)
                }
                .cornerRadius(6)
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

// terminal.swift — a terminal-styled cmux sidebar that FOLLOWS the app's
// light/dark appearance (adaptive DSL tokens, no hardcoded hex). Each row is a
// single button (tap = select the workspace) surfacing the full snapshot:
// title · PR · description · git branch/dirty · remote · running-server ports ·
// progress · tab count, and the selected workspace's tab list.
//   preview:  cmux sidebar select terminal      edit-in-pane:  cmux sidebar open terminal
// NOTE: use STANDARD presentation mode. Progress is shown as TEXT, not a
// ProgressView — a ProgressView has no intrinsic height cap, so in a VStack it
// expands to fill and forces every row to the same tall height. Keep every row
// child height-bounded (Text/HStack of Text) to preserve terminal density.

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
                Button(action: { cmux("workspace.select", workspace_id: w.id) }) {
                    HStack(spacing: 8) {
                        Text(w.unread > 0 ? "●" : (w.selected ? "▸" : "○"))
                            .font(.caption).fontDesign(.monospaced)
                            .foregroundColor(w.unread > 0 ? "red" : (w.selected ? "green" : "tertiary"))

                        VStack(alignment: .leading, spacing: 2) {
                            // title + PR badge
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

                            // detail text
                            if let d = w.description {
                                Text(d).foregroundColor("tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
                            }

                            // branch · dirty · remote · ports · tabs · progress (all leaf text)
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
                                for p in w.ports {
                                    Text(":\(p)").foregroundColor("green").fontDesign(.monospaced).font(.caption)
                                }
                                if w.tabCount > 0 {
                                    Text("\(w.tabCount)⊞").foregroundColor("tertiary").fontDesign(.monospaced).font(.caption)
                                }
                                if let pg = w.progress {
                                    Text("\(Int(pg.value * 100))%").foregroundColor("accent").fontDesign(.monospaced).font(.caption)
                                }
                            }

                            // selected workspace: tab (surface) list for reference
                            if w.selected {
                                for t in w.tabs.prefix(8) {
                                    HStack(spacing: 5) {
                                        Text(t.focused ? "▸" : "·")
                                            .foregroundColor(t.focused ? "accent" : "tertiary").fontDesign(.monospaced).font(.caption2)
                                        Text(t.title)
                                            .foregroundColor(t.focused ? "secondary" : "tertiary").fontDesign(.monospaced).font(.caption2).lineLimit(1)
                                    }
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
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(w.selected ? "quaternary" : "clear")
                    .overlay(alignment: .leading) {
                        Rectangle().fill(w.selected ? "accent" : "clear").frame(width: 3)
                    }
                    .cornerRadius(6)
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

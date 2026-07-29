// terminal.swift — a cmux sidebar that reads like a terminal and FOLLOWS the
// app's light/dark appearance automatically (adaptive DSL tokens, no hardcoded
// hex). Sections: prompt header · running servers · workspace list · footer.
//   preview in the left sidebar:  cmux sidebar select terminal
//   open as a pane while editing:  cmux sidebar open terminal
// NOTE: use STANDARD presentation mode with this sidebar (minimal mode's native
// controls can't render inside a custom sidebar).

VStack(alignment: .leading, spacing: 0) {

    // ── prompt-style header ─────────────────────────────────────────────
    HStack(spacing: 6) {
        Text("➜").foregroundColor("green").fontDesign(.monospaced).bold()
        Text("cmux").foregroundColor("accent").fontDesign(.monospaced).bold()
        Text("workspaces").foregroundColor("secondary").fontDesign(.monospaced)
        Spacer()
        Text(clock.time)
            .foregroundColor("secondary")
            .fontDesign(.monospaced)
            .monospacedDigit()
            .font(.caption)
    }
    .padding(10)

    Rectangle().fill("quaternary").frame(height: 1).frame(maxWidth: .infinity)

    // ── running servers ─────────────────────────────────────────────────
    // Any workspace with a detected listening port. Tap a row to jump to the
    // workspace running that server. Section hides itself when nothing listens.
    let serverWorkspaces = workspaces.filter { $0.portCount > 0 }
    if serverWorkspaces.count > 0 {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 6) {
                Text("◆").foregroundColor("green").font(.caption)
                Text("servers").foregroundColor("secondary").fontDesign(.monospaced).font(.caption)
                Spacer()
                Text("\(serverWorkspaces.count)⇡")
                    .foregroundColor("tertiary").fontDesign(.monospaced).font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 3)

            for w in serverWorkspaces {
                for p in w.ports {
                    Button(action: { cmux("workspace.select", workspace_id: w.id) }) {
                        HStack(spacing: 8) {
                            Text(w.selected ? "▸" : "·")
                                .foregroundColor(w.selected ? "green" : "tertiary")
                                .fontDesign(.monospaced).font(.caption)
                            Text(":\(p)")
                                .foregroundColor("cyan").fontDesign(.monospaced).font(.caption).bold()
                            Text(w.title)
                                .foregroundColor("secondary").fontDesign(.monospaced).font(.caption).lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(w.selected ? "quaternary" : "clear")
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.bottom, 6)
        Rectangle().fill("quaternary").frame(height: 1).frame(maxWidth: .infinity)
    }

    // ── live, tappable, drag-to-reorder workspace list ──────────────────
    ScrollView {
        VStack(alignment: .leading, spacing: 1) {
            Reorderable(workspaces, move: "workspace.reorder") { w in
                Button(action: { cmux("workspace.select", workspace_id: w.id) }) {
                    HStack(spacing: 8) {
                        Text(w.unread > 0 ? "●" : (w.selected ? "▸" : "○"))
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundColor(w.unread > 0 ? "red" : (w.selected ? "green" : "tertiary"))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(w.title)
                                .foregroundColor(w.selected ? "primary" : "secondary")
                                .fontDesign(.monospaced)
                                .lineLimit(1)

                            // metadata line — branch · dirty · ports · tabs
                            HStack(spacing: 8) {
                                if let b = w.branch {
                                    HStack(spacing: 3) {
                                        Text("⎇").foregroundColor("cyan").font(.caption)
                                        Text(b)
                                            .foregroundColor("secondary")
                                            .fontDesign(.monospaced)
                                            .font(.caption)
                                            .lineLimit(1)
                                        if w.dirty {
                                            Text("✳").foregroundColor("orange").font(.caption)
                                        }
                                    }
                                }
                                if w.portCount > 0 {
                                    Text(":\(w.portCount)p")
                                        .foregroundColor("secondary")
                                        .fontDesign(.monospaced)
                                        .font(.caption)
                                }
                                if w.tabCount > 0 {
                                    Text("\(w.tabCount)⊞")
                                        .foregroundColor("tertiary")
                                        .fontDesign(.monospaced)
                                        .font(.caption)
                                }
                            }
                        }

                        Spacer()

                        if w.unread > 0 {
                            Text("\(w.unread)")
                                .foregroundColor("white")
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .bold()
                                .padding(4)
                                .background("red")
                                .cornerRadius(6)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(w.selected ? "quaternary" : "clear")
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(w.selected ? "accent" : "clear")
                            .frame(width: 3)
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
            Text("● \(unreadTotal) unread")
                .foregroundColor("red").fontDesign(.monospaced).font(.caption)
        } else {
            Text("● clear")
                .foregroundColor("green").fontDesign(.monospaced).font(.caption)
        }
    }
    .padding(10)
}
.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

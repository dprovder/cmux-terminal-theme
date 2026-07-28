// terminal.swift — a cmux sidebar that reads like a terminal and FOLLOWS the
// app's light/dark appearance automatically. No hardcoded hex: it uses the
// DSL's adaptive tokens (primary/secondary/tertiary/quaternary = auto light/dark,
// accent = theme accent, and system color names like red/green/cyan). The root
// paints no background, so `sidebarAppearance.matchTerminalBackground` fills the
// container with the current terminal bg (which already tracks the toggle).
// Live workspaces: tap to select, drag to reorder. Hot-reloads on save.
//   preview in the left sidebar:  cmux sidebar select terminal
//   open as a pane while editing:  cmux sidebar open terminal
// NOTE: use STANDARD presentation mode with this sidebar. Minimal mode tries to
// draw cmux's native workspace controls INTO the sidebar, which a custom sidebar
// can't render (you get blank gray button backgrounds).

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

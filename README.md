# Inkscape Agent

An experimental foundation for a cross-platform agent capable of controlling Inkscape comprehensively.

## Goal

The project aims to let an agent safely read and modify an entire Inkscape document:

- SVG objects, groups, layers, text, and styles;
- Inkscape pages, guides, and metadata;
- exact dimensions, positions, transforms, and alignment;
- exports and other Inkscape actions;
- live updates of an open document;
- change previews, operation audits, backups, and rollback.

The project is intended to be cross-platform. The XML/SVG core must therefore remain operating-system independent, while communication with the running application is implemented through Linux, Windows, and macOS adapters.

## Current status

The following workflow has been tested successfully on Linux:

1. A running Inkscape instance publishes `org.inkscape.Inkscape` on the user session D-Bus.
2. The agent activates the `file-rebase` application action with the value `true`.
3. The agent calls `org.gtk.Application.Open` with the URI of the modified SVG.
4. The active document updates immediately.
5. Window actions such as `canvas-zoom-page` can be invoked directly over D-Bus.

The Windows and macOS transports have not been verified yet.

## Quick Linux test

Open a disposable test document in Inkscape and run:

```bash
./scripts/linux/rebase-active.sh examples/a4-landscape-test.svg
```

The script replaces the contents of the active document. Use it only with a test document or a saved backup.

## Proposed architecture

```text
user request
     ↓
safe operation planner
     ↓
platform-independent SVG/XML core
     ↓
validation + diff + backup
     ↓
transport adapter
  ├── Linux: D-Bus / GApplication
  ├── Windows: Inkscape CLI / bridge / extension
  └── macOS: CLI / bridge / extension
     ↓
running Inkscape instance
```

Start with [docs/HANDOVER.md](docs/HANDOVER.md) when resuming the project. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for design details and [docs/EXPERIMENT-2026-09-25.md](docs/EXPERIMENT-2026-09-25.md) for the first experiment log.

## Safety rules

- Never silently overwrite a document containing unsaved manual changes.
- Create a backup or working copy before a destructive operation.
- Prefer structured operations over unrestricted replacement of the entire XML document.
- Preserve namespaces, IDs, and references such as `url(#id)`, `href`, masks, and clips.
- Validate SVG before passing it to Inkscape.
- Present a summary of added, changed, and removed nodes.
- Never commit credentials, access tokens, private keys, personal data, or machine-specific secrets.

## Roadmap

- [x] Verify control of a running Inkscape instance over Linux D-Bus.
- [x] Verify live document updates through `file-rebase`.
- [x] Verify objects, text, pages, and guides.
- [ ] Read the latest document state before every change.
- [ ] Implement structured XML operations and diffs.
- [ ] Add automatic backups and transactions.
- [ ] Verify Inkscape CLI and `--active-window` on Windows.
- [ ] Evaluate a cross-platform Inkscape extension as a shared bridge.
- [ ] Add a macOS adapter.
- [ ] Create a Codex skill for the repeatable workflow.
- [ ] Consider an MCP server for a stable tool interface.

## License

No license has been selected yet.

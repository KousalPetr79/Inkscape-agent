# Architecture

## Core decision

The agent must not depend on a single GUI automation mechanism. An Inkscape document is SVG/XML, so the primary logic operates on the document tree. Communication with the running application is a separate layer.

## System layers

### 1. Document core

A platform-independent library for:

- safe SVG parsing and serialization;
- preservation of Inkscape and Sodipodi namespaces;
- queries by ID, type, layer, and selector;
- objects, pages, and guides;
- geometry units and conversions;
- structured operations;
- validation of references between nodes.

### 2. Operation model

The model should not normally return a complete replacement SVG. The preferred output is a list of inspectable operations:

```json
[
  {
    "operation": "set_attribute",
    "id": "rect42",
    "name": "x",
    "value": "98.5"
  },
  {
    "operation": "add_guide",
    "axis": "x",
    "position_mm": 148.5
  }
]
```

Every operation must be validated before it is applied.

### 3. Transaction layer

Before making a change:

1. Obtain the latest document state.
2. Detect unsaved manual changes.
3. Create a backup or snapshot.
4. Apply operations to a working copy.
5. Validate XML and references.
6. Present a diff.
7. Update Inkscape.
8. Verify the result.

### 4. Transport adapters

#### Linux

The tested discovery and action path uses GTK/GApplication over the session D-Bus:

- service: `org.inkscape.Inkscape`;
- application object: `/org/inkscape/Inkscape`;
- window: `/org/inkscape/Inkscape/window/1`;
- document: `/org/inkscape/Inkscape/document/1`.

Direct window actions are confirmed. Active-document replacement is not confirmed: a two-call `file-rebase` followed by `org.gtk.Application.Open` opened a new window because the rebase state did not carry across the separate calls.

#### Windows

Candidates to test:

1. `inkscape.com --active-window --actions=...`;
2. a standard Python/inkex Inkscape extension;
3. a local bridge communicating with the extension;
4. controlled saving and reloading of the document.

D-Bus must not be treated as a general Windows solution.

#### macOS

Candidates include the CLI, an Inkscape extension, or a local bridge. The transport will be selected after practical testing.

## Long-term direction

A small Inkscape extension may provide the best shared cross-platform layer. It could expose a restricted local API through which the agent sends structured operations. The extension would apply them to the live document with Undo support.

## Open problems

- Reliably reading an unsaved live document.
- Updating the active document without opening a new window.
- Preserving Inkscape Undo history across a rebase.
- Synchronizing manual and agent changes.
- Selecting the correct window when multiple documents are open.
- Resolving conflicts safely.
- Maintaining compatibility across Inkscape versions.

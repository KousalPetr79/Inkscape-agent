# Linux/D-Bus experiment — 2026-09-25

## Environment

- Linux desktop with a session D-Bus.
- Inkscape running as an AppImage.
- The `org.inkscape.Inkscape` service was present on the bus.
- Inkscape exported application, window, and document `org.gtk.Actions` groups.

## Verified actions

Non-destructive visual test:

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape/window/1 \
  --method org.gtk.Actions.Activate \
  canvas-zoom-page "[]" "{}"
```

The command changed the active window view to fit the page.

## Document update attempt

Running only:

```bash
inkscape --active-window --actions=file-rebase:true file.svg
```

did not change the active document in the tested AppImage build. A successful process exit is therefore not evidence of a visible update.

A direct two-step D-Bus sequence initially appeared to work because the generated content became visible. Later inspection showed that it opened a new window for every call rather than changing the original active document.

### Step 1: enable rebase mode

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Actions.Activate \
  file-rebase "[<true>]" "{}"
```

### Step 2: pass the SVG to the same instance

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Application.Open \
  "['file:///absolute/path/file.svg']" "" "{}"
```

This sequence did **not** replace the live contents of the original test document. It opened the supplied SVG as a new document window. After four edits, D-Bus introspection showed `window/1` through `window/4` and `document/1` through `document/4`.

The likely reason is that `file-rebase(true)` and `Application.Open` were separate D-Bus calls, so the rebase intent did not carry into the later open operation. This remains a hypothesis until the Inkscape implementation is inspected or a single atomic invocation is found.

## Content tested in practice

- An A4 landscape page, 297 × 210 mm.
- Guides 5 mm from every edge.
- A vertical center guide at x = 148.5 mm.
- A 100 × 50 mm rectangle.
- `Test` text using `textLength="50"`.
- Moving the rectangle and text to the center guide.

## Important findings

- Inkscape's XML Editor operates on the live internal XML tree.
- The tested two-call sequence opens a new window and must not be described as an active-document rebase.
- A D-Bus `()` response confirms that the call was accepted, not that the visual result is correct.
- Result verification must be part of the future adapter.
- Stable object IDs and document structure are essential for targeted changes.

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

## Verified document update

Running only:

```bash
inkscape --active-window --actions=file-rebase:true file.svg
```

did not change the active document in the tested AppImage build. A successful process exit is therefore not evidence of a visible update.

A direct two-step D-Bus sequence worked.

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

This sequence replaced the live contents of the active test document.

## Content tested in practice

- An A4 landscape page, 297 × 210 mm.
- Guides 5 mm from every edge.
- A vertical center guide at x = 148.5 mm.
- A 100 × 50 mm rectangle.
- `Test` text using `textLength="50"`.
- Moving the rectangle and text to the center guide.

## Important findings

- Inkscape's XML Editor operates on the live internal XML tree.
- An external rebase replaces the entire tree and can overwrite unsaved manual changes.
- A D-Bus `()` response confirms that the call was accepted, not that the visual result is correct.
- Result verification must be part of the future adapter.
- Stable object IDs and document structure are essential for targeted changes.

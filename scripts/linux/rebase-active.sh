#!/usr/bin/env bash
set -euo pipefail

echo "This experiment is disabled: the tested D-Bus sequence opens a new Inkscape window instead of updating the active document." >&2
echo "See docs/EXPERIMENT-2026-09-25.md for details." >&2
exit 5

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /absolute/path/document.svg" >&2
  exit 2
fi

svg_path=$(realpath "$1")
if [[ ! -f "$svg_path" ]]; then
  echo "File does not exist: $svg_path" >&2
  exit 2
fi

if ! command -v gdbus >/dev/null 2>&1; then
  echo "The gdbus command is required." >&2
  exit 3
fi

if ! gdbus call --session \
  --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.NameHasOwner \
  org.inkscape.Inkscape | grep -q true; then
  echo "No running Inkscape instance was found on the session D-Bus." >&2
  exit 4
fi

svg_uri=$(python3 -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).as_uri())' "$svg_path")

gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Actions.Activate \
  file-rebase "[<true>]" "{}"

gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Application.Open \
  "['$svg_uri']" "" "{}"

gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape/window/1 \
  --method org.gtk.Actions.Activate \
  canvas-zoom-page "[]" "{}"

echo "The active document was updated from: $svg_path"

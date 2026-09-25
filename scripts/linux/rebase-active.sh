#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Použití: $0 /absolutni/cesta/dokument.svg" >&2
  exit 2
fi

svg_path=$(realpath "$1")
if [[ ! -f "$svg_path" ]]; then
  echo "Soubor neexistuje: $svg_path" >&2
  exit 2
fi

if ! command -v gdbus >/dev/null 2>&1; then
  echo "Chybí příkaz gdbus." >&2
  exit 3
fi

if ! gdbus call --session \
  --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.NameHasOwner \
  org.inkscape.Inkscape | grep -q true; then
  echo "Běžící Inkscape nebyl na session D-Bus nalezen." >&2
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

echo "Aktivní dokument byl aktualizován z: $svg_path"

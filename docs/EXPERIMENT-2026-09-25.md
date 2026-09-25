# Linux/D-Bus experiment — 2026-09-25

## Prostředí

- Linux desktop se session D-Bus.
- Inkscape spuštěný jako AppImage.
- Na sběrnici byla nalezena služba `org.inkscape.Inkscape`.
- Inkscape exportoval aplikační, okenní a dokumentové skupiny `org.gtk.Actions`.

## Ověřené akce

Neškodný vizuální test:

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape/window/1 \
  --method org.gtk.Actions.Activate \
  canvas-zoom-page "[]" "{}"
```

Příkaz změnil pohled aktivního okna na celou stránku.

## Ověřená aktualizace dokumentu

Samotné spuštění:

```bash
inkscape --active-window --actions=file-rebase:true file.svg
```

v testovaném AppImage aktivní dokument nezměnilo. Úspěšný návratový kód proto není důkazem vizuální změny.

Funkční byla až přímá dvoukroková D-Bus sekvence.

### Krok 1: aktivace režimu rebase

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Actions.Activate \
  file-rebase "[<true>]" "{}"
```

### Krok 2: předání SVG stejné instanci

```bash
gdbus call --session \
  --dest org.inkscape.Inkscape \
  --object-path /org/inkscape/Inkscape \
  --method org.gtk.Application.Open \
  "['file:///absolutni/cesta/file.svg']" "" "{}"
```

Tato sekvence nahradila živý obsah aktivního testovacího dokumentu.

## Prakticky ověřený obsah

- stránka A4 na šířku, 297 × 210 mm,
- vodítka 5 mm od všech okrajů,
- svislé středové vodítko na x = 148,5 mm,
- obdélník 100 × 50 mm,
- text `Test` s `textLength="50"`,
- přesun obdélníku a textu na středové vodítko.

## Důležité poznatky

- XML Editor Inkscape pracuje se živým interním XML stromem.
- Externí rebase nahrazuje celý strom a může přepsat neuložené ruční změny.
- D-Bus odpověď `()` potvrzuje přijetí volání, nikoliv sama o sobě správný vizuální výsledek.
- Ověření výsledku musí být součástí budoucího adaptéru.
- ID objektů a stabilní struktura dokumentu jsou zásadní pro cílené změny.

# Architektura

## Zásadní rozhodnutí

Agent nemá být svázán s jedním způsobem ovládání GUI. Inkscape dokument je SVG/XML, takže hlavní logika bude pracovat nad dokumentovým stromem. Komunikace s běžící aplikací bude samostatná vrstva.

## Vrstvy systému

### 1. Document core

Platformně nezávislá knihovna pro:

- načtení a bezpečný zápis SVG,
- zachování Inkscape a Sodipodi namespaces,
- vyhledávání podle ID, typu, vrstvy a selektoru,
- objekty, stránky a vodítka,
- geometrické jednotky a převody,
- strukturované operace,
- validaci odkazů mezi uzly.

### 2. Operation model

Model by neměl běžně vracet celý nový SVG dokument. Preferovaný výstup je seznam kontrolovatelných operací:

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

Každá operace musí být validována před aplikací.

### 3. Transaction layer

Před změnou:

1. získat nejnovější stav dokumentu,
2. zjistit, zda nejsou neuložené ruční změny,
3. vytvořit zálohu nebo snapshot,
4. aplikovat operace do pracovní kopie,
5. validovat XML a odkazy,
6. zobrazit diff,
7. aktualizovat Inkscape,
8. potvrdit výsledek.

### 4. Transport adapters

#### Linux

Ověřená cesta používá GTK/GApplication přes session D-Bus:

- služba: `org.inkscape.Inkscape`,
- aplikační objekt: `/org/inkscape/Inkscape`,
- okno: `/org/inkscape/Inkscape/window/1`,
- dokument: `/org/inkscape/Inkscape/document/1`.

#### Windows

Kandidáti k ověření:

1. `inkscape.com --active-window --actions=...`,
2. standardní Inkscape extension v Pythonu/inkex,
3. lokální bridge komunikující s rozšířením,
4. řízené uložení a opětovné načtení dokumentu.

D-Bus nelze považovat za obecné řešení pro Windows.

#### macOS

Kandidáti jsou CLI, Inkscape extension nebo lokální bridge. Přesný mechanismus bude vybrán po praktickém testu.

## Dlouhodobý cíl

Nejlepší společnou multiplatformní vrstvou může být malé Inkscape rozšíření, které agentovi nabídne omezené lokální API. Agent by posílal strukturované operace a rozšíření by je aplikovalo do živého dokumentu s podporou Undo.

## Co zatím není vyřešeno

- spolehlivé načtení neuloženého živého dokumentu,
- zachování Inkscape Undo historie při rebase,
- synchronizace ručních a agentních změn,
- výběr správného okna při více otevřených dokumentech,
- bezpečné řešení konfliktů,
- kompatibilita mezi verzemi Inkscape.

# Inkscape Agent

Experimentální základ multiplatformního agenta pro kompletní ovládání Inkscape.

## Záměr

Cílem projektu je umožnit agentovi bezpečně číst a upravovat celý Inkscape dokument:

- SVG objekty, skupiny, vrstvy, texty a styly,
- stránky, vodítka a metadata Inkscape,
- přesné rozměry, pozice, transformace a zarovnání,
- exporty a další akce Inkscape,
- živou aktualizaci otevřeného dokumentu,
- náhled změn, audit operací, zálohy a návrat změn.

Projekt má být multiplatformní. XML/SVG jádro proto musí být nezávislé na operačním systému a ovládání běžící aplikace bude řešeno adaptéry pro Linux, Windows a macOS.

## Aktuální stav

Na Linuxu byl prakticky ověřen tento postup:

1. běžící Inkscape publikuje `org.inkscape.Inkscape` na uživatelském D-Bus,
2. agent aktivuje aplikační akci `file-rebase` s hodnotou `true`,
3. agent zavolá `org.gtk.Application.Open` s URI upraveného SVG,
4. obsah aktivního dokumentu se okamžitě aktualizuje,
5. okenní akce jako `canvas-zoom-page` lze volat přímo přes D-Bus.

Windows a macOS transport zatím nebyl ověřen.

## Rychlý Linux test

Otevřete v Inkscape libovolný testovací dokument a spusťte:

```bash
./scripts/linux/rebase-active.sh examples/a4-landscape-test.svg
```

Skript nahradí obsah aktivního dokumentu. Používejte pouze testovací dokument nebo předem uloženou kopii.

## Navržená architektura

```text
uživatelský požadavek
        ↓
plánovač bezpečných operací
        ↓
platformně nezávislé SVG/XML jádro
        ↓
validace + diff + záloha
        ↓
transportní adaptér
  ├── Linux: D-Bus / GApplication
  ├── Windows: Inkscape CLI / bridge / extension
  └── macOS: CLI / bridge / extension
        ↓
běžící Inkscape
```

Podrobnosti jsou v [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) a průběh prvního experimentu v [docs/EXPERIMENT-2026-09-25.md](docs/EXPERIMENT-2026-09-25.md).

## Bezpečnostní pravidla

- Nikdy tiše nepřepisovat dokument, který obsahuje neuložené ruční změny.
- Před destruktivní operací vytvořit zálohu nebo pracovní kopii.
- Preferovat strukturované operace nad volným přepisem celého XML.
- Zachovat namespace, ID a odkazy jako `url(#id)`, `href`, masky a klipy.
- Validovat SVG před předáním Inkscape.
- Zobrazit uživateli přehled přidaných, změněných a odstraněných uzlů.

## Roadmap

- [x] Ověřit řízení běžícího Inkscape přes Linux D-Bus.
- [x] Ověřit živou aktualizaci dokumentu pomocí `file-rebase`.
- [x] Ověřit objekty, text, stránky a vodítka.
- [ ] Číst nejnovější stav dokumentu před každou změnou.
- [ ] Implementovat strukturované XML operace a diff.
- [ ] Přidat automatické zálohy a transakce.
- [ ] Ověřit Inkscape CLI a `--active-window` na Windows.
- [ ] Vyhodnotit multiplatformní Inkscape extension jako společný bridge.
- [ ] Přidat macOS adaptér.
- [ ] Vytvořit Codex skill pro opakovatelný pracovní postup.
- [ ] Později zvážit MCP server pro stabilní sadu nástrojů.

## Licence

Licence zatím nebyla zvolena.

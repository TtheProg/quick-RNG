# Quick RNG

Ein minimaler Zufallsgenerator für macOS, der in der Menüleiste wohnt.

Icon anklicken (oder **⌥⌘R**) → der Cursor steht schon im Eingabefeld → tippen →
**Return** → Ergebnis. Der Text ist danach komplett markiert: nochmal Return
würfelt neu, Tippen überschreibt.

Ein Feld für alles. Was du eingibst, entscheidet, was gewürfelt wird — der Chip
oben rechts zeigt dir schon beim Tippen, wie die Eingabe verstanden wurde.

## Eingaben

| Eingabe | Ergebnis |
|---|---|
| *(leer)* | Zahl von 1 bis 100 |
| `100` | Zahl von 1 bis 100 |
| `3 - 9` · `3..9` · `3 bis 9` | Ganzzahl im Bereich |
| `1.5 - 2.5` | Kommazahl im Bereich |
| `rot, grün, blau` | eine der Optionen |
| `ja / nein` | eine der Optionen (`,` `;` `\|` `/` trennen) |
| `3x a, b, c, d` | drei verschiedene Optionen |
| `shuffle a, b, c` | die komplette Reihenfolge |
| `2d6` · `d20` · `3w8+2` | Würfel, mit Einzelwürfen darunter |
| `01.01.2026 - 31.12.2026` | Datum im Zeitraum |
| `münze` · `coin` | Kopf oder Zahl |

Datumsformate: `TT.MM.JJJJ`, `TT.MM.JJ`, `JJJJ-MM-TT`, `TT/MM/JJJJ`.

## Bedienung

| Taste | |
|---|---|
| `Return` | würfeln (und danach nochmal für neu) |
| `↑` / `↓` | durch frühere Eingaben blättern |
| `esc` | Panel bzw. Anleitung schließen |
| `⌥⌘R` | Panel öffnen und wieder schließen — in der Anleitung änderbar |

Rechtsklick aufs Menüleisten-Icon (oder das `···` im Panel): als Fenster öffnen,
Anleitung, bei Anmeldung starten, beenden.

Die ausführliche **[Anleitung](ANLEITUNG.md)** steckt auch in der App — `?` im
Panel und im Fenster.

Das **Fenster** ist dasselbe Tool mit mehr Platz — plus Verlauf (Eintrag
anklicken übernimmt die Eingabe wieder) und einem Spickzettel. Solange es offen
ist, hat die App ein Dock-Icon; danach lebt sie wieder nur in der Menüleiste.

## Bauen

Braucht nur die Xcode Command Line Tools, kein Xcode-Projekt.

```bash
./build.sh --install
```

Baut `build/Quick RNG.app`, legt sie nach `/Applications` (eine vorhandene
Version wandert in den Papierkorb) und startet sie. Ohne `--install` wird nur
gebaut. Die Signatur ist ad-hoc — beim ersten Start ggf. Rechtsklick → Öffnen.

Im Terminal geht auch direkt:

```bash
"/Applications/Quick RNG.app/Contents/MacOS/QuickRNG" --roll "2d6"
```

## Aufbau

```
Sources/QuickRNG/
  Core/     Parser (Text → Request), Roller (Request → Ergebnis), AppState
  UI/       Theme, PanelView, WindowView, ResultView, RollField
  App/      AppDelegate, PanelController, WindowController, HotKey, LoginItem
```

Ein paar Entscheidungen, die nicht offensichtlich sind:

- **`RollField` ist ein `NSTextField`**, kein SwiftUI-`TextField`. SwiftUI kann
  seinen Inhalt nicht auf Kommando markieren, und der Fokus ist in einem
  nicht-aktivierenden Panel unzuverlässig — beides braucht diese App.
- **Das Panel ist ein `NSPanel`** mit `.nonactivatingPanel`, damit die Tastatur
  im Feld landet, ohne die App im Vordergrund zu verdrängen.
- **Farben sind dynamische `NSColor`s**, die sich pro Erscheinungsbild selbst
  auflösen — Light Mode ist ein eigenes Design, nicht das dunkle mit Licht an.
- **Das Menüleisten-Icon ist gezeichnet**, nicht `die.face.5`: das SF Symbol
  rendert hauchdünn und zu klein neben allem anderen da oben.

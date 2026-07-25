# Anleitung

Dieselbe Anleitung steckt auch in der App — `?` im Panel, `?` im Fenster oder
Rechtsklick aufs Menüleisten-Icon → **Anleitung**.

## Schnellstart

1. Auf das Würfel-Icon oben in der Menüleiste klicken — oder **⌥⌘R** drücken.
2. Der Cursor steht schon im Feld. Tippen.
3. **Return** — das Ergebnis steht groß da.
4. Der Text ist jetzt komplett markiert. **Return** würfelt dasselbe nochmal,
   Tippen überschreibt die Eingabe.

Der Chip oben rechts sagt dir schon beim Tippen, wie deine Eingabe verstanden
wurde (`1–100`, `4 Optionen`, `2d6`, `01.01.26 – 31.12.26`, …). Passt er nicht,
siehst du das, bevor du Return drückst. Die Akzentfarbe wechselt mit — Zahlen
sind mint, Listen violett, Würfel bernstein, Daten blau, Münze pink, Mischen
türkis.

## Eingaben

### Zahlen

| Eingabe | Ergebnis |
|---|---|
| *(leer)* | 1 – 100 |
| `100` | 1 – 100 |
| `3 - 9` | Ganzzahl von 3 bis 9 |
| `3..9` · `3...9` · `3 bis 9` · `3 to 9` | dasselbe |
| `-5 - 5` | negative Grenzen gehen auch |
| `1.5 - 2.5` | Kommazahl, Nachkommastellen wie eingegeben |
| `1,5 - 2,5` | Komma als Dezimaltrennzeichen geht auch |

### Listen

| Eingabe | Ergebnis |
|---|---|
| `rot, grün, blau` | eine der drei |
| `ja / nein` | eine der beiden |
| `a; b; c` · `a \| b \| c` | Trennzeichen: `,` `;` `\|` `/` |
| `3x rot, grün, blau, gelb` | drei **verschiedene** |
| `3 aus a, b, c, d` | dasselbe — `x` `aus` `von` `of` |
| `shuffle a, b, c` | die ganze Reihenfolge, nummeriert |
| `mische a, b, c` | dasselbe — `shuffle` `mische` `misch` `mix` |

### Würfel

| Eingabe | Ergebnis |
|---|---|
| `2d6` | Summe, darunter die Einzelwürfe |
| `d20` | ein zwanzigseitiger |
| `3w8+2` | deutsches `w` und Modifikator gehen auch |
| `4d6-1` | Modifikator kann negativ sein |

### Datum

| Eingabe | Ergebnis |
|---|---|
| `01.01.2026 - 31.12.2026` | ein zufälliger Tag im Zeitraum |
| `1.1.26 - 31.12.26` | zweistellige Jahre gehen auch |
| `2026-01-01 - 2026-12-31` | ISO |
| `01/01/2026 - 31/12/2026` | Tag/Monat/Jahr |

Beide Grenzen sind eingeschlossen. Die Reihenfolge ist egal.

### Münze

`münze` · `muenze` · `coin` · `flip` · `toss` → **Kopf** oder **Zahl**.

## Tasten

| Taste | |
|---|---|
| `Return` | würfeln — und gleich nochmal für einen neuen Wurf |
| `↑` / `↓` | durch frühere Eingaben blättern |
| `esc` | Panel schließen · Anleitung schließen · im Fenster: Feld leeren |
| `⌥⌘R` | Panel von überall öffnen |

### Kurzbefehl ändern

In der Anleitung **in der App** (`?` im Panel) steht unter *Einstellungen* das
Feld **Kurzbefehl**. Draufklicken, die gewünschte Kombination drücken, fertig.
`esc` bricht ab, `⌫` entfernt den Kurzbefehl ganz — das Menüleisten-Icon
funktioniert dann weiterhin.

Mindestens ein Modifikator (`⌘` `⌥` `⌃`) muss dabei sein, sonst würde die
Kombination systemweit normales Tippen abfangen. Hat schon eine andere App die
Kombination, steht das direkt unter dem Feld.

## Menüleiste und Fenster

**Panel** (Klick aufs Icon): das Schnelle. Öffnet sich unter dem Icon, nimmt
sofort die Tastatur, schließt sich, sobald du woanders hinklickst.

**Fenster** (`⌘`-loses Klicken auf das Fenster-Symbol im Panel, oder Rechtsklick
aufs Icon → *Als Fenster öffnen*): dasselbe Tool mit mehr Platz, dazu der
**Verlauf**. Ein Eintrag im Verlauf angeklickt übernimmt dessen Eingabe wieder
ins Feld. Solange ein Fenster offen ist, hat die App ein Dock-Icon; danach lebt
sie wieder nur in der Menüleiste.

**Rechtsklick aufs Icon**: als Fenster öffnen · Anleitung · bei Anmeldung
starten · beenden.

## Terminal

Die App ist gleichzeitig ein kleines CLI:

```bash
"/Applications/Quick RNG.app/Contents/MacOS/QuickRNG" --roll "2d6"
```

`--verbose` hängt die Herleitung an (`2d6 · 4 + 5`). Praktisch für ein Alias:

```bash
alias rng='"/Applications/Quick RNG.app/Contents/MacOS/QuickRNG" --roll'
```

## Wenn etwas nicht geht

**Der Chip sagt „versteh ich nicht"** — die Eingabe passt in kein Muster. Meist
fehlt ein Trennzeichen (`rot grün blau` statt `rot, grün, blau`) oder eine
Bereichsgrenze (`3-` statt `3-9`).

**⌥⌘R tut nichts** — dann hat eine andere App die Kombination. Unter
*Einstellungen → Kurzbefehl* in der App steht das dann auch da; einfach eine
andere Kombination aufnehmen.

**Beim ersten Start: „nicht verifizierter Entwickler"** — die App ist ad-hoc
signiert. Rechtsklick auf die App → *Öffnen* → *Öffnen*.

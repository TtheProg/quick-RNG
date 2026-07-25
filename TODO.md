# TODO

## Als Nächstes

- [ ] **Mehrsprachigkeit — Deutsch, Englisch, Arabisch.** Die Sprache folgt
      automatisch der Systemsprache, wenn sie vorhanden ist, sonst Englisch;
      zusätzlich in den Einstellungen (Anleitung → Einstellungen) fest
      wählbar. Betrifft alle UI-Strings, `ANLEITUNG.md`, `GuideView`,
      `WindowView.syntax` und die Ergebnistexte („Kopf"/„Zahl", „aus 365
      Tagen", „aus 4 Optionen").
      Für Arabisch kommt RTL dazu: Layout spiegeln, aber die Eingabe- und
      Ergebniszeile bleibt LTR, weil dort Zahlen und Syntax stehen.
      Der Parser versteht deutsche *und* englische Schlüsselwörter bereits
      (`bis`/`to`, `mische`/`shuffle`, `münze`/`coin`, `w`/`d`) — arabische
      müssten ergänzt werden, und zwar sprachunabhängig: eine arabische
      Oberfläche darf `2d6` nicht ablehnen. — `⌘C` legt das Ergebnis in die Zwischenablage,
      ohne dass man es markieren muss. Für ein Tool, mit dem man eine Zahl
      *holt*, ist das der offensichtlichste fehlende Schritt.
- [ ] **Gewichtete Listen** — `rot*3, grün, blau` zieht rot dreimal so oft.
- [ ] **Ohne Zurücklegen** — dieselbe Liste mehrfach ziehen, ohne dass sich
      etwas wiederholt, bis alles durch ist (Sitzordnung, Losverfahren).
- [ ] **Favoriten** — häufige Eingaben anpinnen und mit `⌘1`–`⌘9` direkt
      würfeln, ohne zu tippen.

## Eingaben, die noch fehlen

- [ ] `heute + 30 Tage` / Zeitraum relativ zu heute
- [ ] Uhrzeiten (`09:00 - 17:00`)
- [ ] Buchstaben-/Zeichenketten (`8 Zeichen`, Passwort-artig)
- [ ] Prozent-Chance (`30%` → ja/nein)

## Feinschliff

- [ ] Verlauf über Neustarts hinweg sichern (nur die Eingaben werden bisher
      gemerkt, nicht die Ergebnisse).
- [ ] Panel-Breite an lange Ergebnisse anpassen (lange Listen schrumpfen die
      Schrift stark, statt breiter zu werden).
- [ ] `shuffle` mit vielen Einträgen scrollbar machen statt auf 6 Zeilen zu
      begrenzen.
- [ ] Sinnvollere Fehlermeldung als „versteh ich nicht" — sagen, *woran* es
      liegt (fehlendes Trennzeichen, halber Bereich).

## Technisch

- [ ] Unit-Tests für den Parser. Es gibt aktuell nur `--roll` als manuelle
      Prüfung; die Trennzeichen-/Datums-Heuristik verdient echte Tests.
- [ ] Richtige Signatur + Notarisierung, damit die App ohne Rechtsklick-Öffnen
      startet.
- [ ] Sparkle o. ä. für Updates — oder bewusst darauf verzichten und per
      `build.sh --install` aktualisieren.

## Bewusst nicht geplant

- Keine Einstellungen-Fenster-Orgie. Was nicht ins Panel passt, gehört nicht rein.
- Kein Sync, kein Account, kein Netzwerk. Die App fasst nichts an außer
  `UserDefaults`.

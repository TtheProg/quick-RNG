# TODO

## Als Nächstes

- [ ] **Ergebnis kopieren** — `⌘C` legt das Ergebnis in die Zwischenablage,
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
- [ ] Englische UI-Strings + Sprachumschaltung (Parser versteht beides schon)

## Feinschliff

- [ ] Kurzbefehl konfigurierbar machen (aktuell fest ⌥⌘R) und melden, wenn er
      belegt ist — momentan schlägt die Registrierung still fehl.
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

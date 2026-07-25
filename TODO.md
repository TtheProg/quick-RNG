# TODO

## Als Nächstes

- [ ] **Mehrsprachigkeit — Deutsch, Englisch, Arabisch.** Die Sprache folgt
      automatisch der Systemsprache, wenn sie vorhanden ist, sonst Englisch;
      zusätzlich in den Einstellungen (`⌘,`) fest wählbar.
      Betrifft alle UI-Strings, `ANLEITUNG.md`, `GuideView`,
      `WindowView.syntax` und die Ergebnistexte („Kopf"/„Zahl", „aus 365
      Tagen", „aus 4 Optionen").
      Für Arabisch kommt RTL dazu: Layout spiegeln, aber die Eingabe- und
      Ergebniszeile bleibt LTR, weil dort Zahlen und Syntax stehen.
      Der Parser versteht deutsche *und* englische Schlüsselwörter bereits
      (`bis`/`to`, `mische`/`shuffle`, `münze`/`coin`, `w`/`d`) — arabische
      müssten ergänzt werden, und zwar sprachunabhängig: eine arabische
      Oberfläche darf `2d6` nicht ablehnen.

- [ ] **Kopier-Button neben jeder Ausgabe.** Ein Kopier-Icon direkt am
      Ergebnis, dazu `⌘C` als Kurzbefehl. Für ein Tool, mit dem man eine Zahl
      *holt*, ist das der offensichtlichste fehlende Schritt — und bei langen
      Zahlen (`14.212.887`) ist Abtippen fehleranfällig.
      Die Tausenderpunkte gehören **nicht** in die Zwischenablage, sondern der
      rohe Wert (`14212887`) — formatiert frisst das kein Zielprogramm. Auch
      pro Zeile im Verlauf, und bei `shuffle` die ganze Liste zeilenweise.
      Feedback direkt am Button („kopiert"), keine Meldung.

- [ ] **Screenshot einfügen → zufällige Zeile per OCR.** Bild einfügen (`⌘V`)
      oder auf die App ziehen, Text zeilenweise erkennen, eine zufällige Zeile
      ausgeben — komplett von Anfang bis Ende.
      Zwei Modi, weil beides vorkommt: **Zeilen** (jede erkannte Textzeile ist
      eine Option) und **Tabelle** (Zeilen über die y-Position gruppieren,
      Spalten über die x-Position — dann zieht man eine ganze Tabellenzeile).
      Technisch `VNRecognizeTextRequest` aus Vision, `.accurate`, mit den
      Bounding-Boxen; die braucht es fürs Gruppieren ohnehin.
      Die eigentliche Arbeit ist die Robustheit, nicht der API-Aufruf:
      - Dark-Mode-Screenshots (heller Text auf dunkel) vorher invertieren,
        Vision erwartet dunkel auf hell. Kleine Schrift vorher hochskalieren.
      - Kontrast/Schwellwert als Vorverarbeitung, weil Themes stark streuen.
      - RTL/Arabisch: `recognitionLanguages` setzen und vorher gegen
        `VNRecognizeTextRequest.supportedRecognitionLanguages()` prüfen statt
        Sprachunterstützung anzunehmen. Zeilen dann von rechts nach links
        sortieren, die x-basierte Spaltenlogik spiegeln. Gemischte Zeilen
        (arabischer Text mit lateinischen Zahlen) gesondert testen — da geht
        die Reihenfolge am schnellsten kaputt.
      - Das Erkannte **vor** dem Würfeln zeigen und korrigierbar machen. OCR
        liegt manchmal daneben; still die falsche Zeile zu ziehen ist schlimmer
        als eine Nachfrage.
      - Leerzeilen, Kopfzeilen und Seitenzahlen aussortieren — mindestens „erste
        Zeile ist eine Überschrift" anbieten.
      Teilt sich die Sprachliste und die RTL-Frage mit der Mehrsprachigkeit.

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

- Die Einstellungen bleiben klein. Alles, was man einmal einstellt und nie
  wieder anfasst, gehört nicht hinein.
- Kein Sync, kein Account, kein Netzwerk. Die App fasst nichts an außer
  `UserDefaults` — auch die OCR läuft lokal über Vision, nicht über einen
  Dienst.

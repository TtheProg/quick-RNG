# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

A native macOS menu bar app: one text field that infers what kind of random
value you want and produces it. Swift 5.9 / SwiftUI + AppKit, built with
SwiftPM — **there is no Xcode project**, and none should be added. Only the
Xcode Command Line Tools are required.

## Build and run

```bash
swift build                     # compile only — cannot run as a menu bar app
./build.sh                      # → build/Quick RNG.app
./build.sh --install            # → /Applications, replaces + launches
```

A bare `swift build` binary has no bundle, so `NSStatusItem` and `LSUIElement`
don't behave. **Always go through `build.sh` when testing UI.**

### Testing without clicking

```bash
.build/debug/QuickRNG --roll "2d6" --verbose   # headless, exercises the parser
```

Flags for driving the UI while developing:

| Flag | |
|---|---|
| `--window` | opens the main window at launch |
| `--open` | opens the menu bar panel at launch |
| `--appearance light\|dark` | forces one appearance without touching the system setting |

`--open` is unreliable when launched from a background shell: the panel needs to
become key, and an inactive app's non-activating panel loses key immediately.
Clicking the status item works. Don't chase this — it isn't a bug in the click
path.

To drive it with AppleScript, **activate the app first** or the keystrokes land
in whatever is frontmost:

```bash
osascript -e 'tell application "System Events" to set frontmost of process "QuickRNG" to true'
```

## Layout

```
Sources/QuickRNG/
  main.swift          entry point; also the --roll CLI branch
  Core/
    Parser.swift      text → Request. The whole product lives here.
    Roller.swift      Request → RollResult
    Request.swift     the parsed intent + its chip label
    Fmt.swift         locale-aware number/date formatting
    AppState.swift    input, result, history, focus/select-all tokens
  UI/
    Theme.swift       dynamic colours, ink levels, the drawn status icon
    PanelView.swift   the menu bar panel
    WindowView.swift  the standalone window (roller + history)
    GuideView.swift   the Anleitung
    ResultView.swift  the headline + the scramble animation + KindChip
    RollField.swift   NSTextField wrapper
  App/
    AppDelegate.swift        status item, hotkey, outside-click monitor
    PanelController.swift    the non-activating NSPanel
    WindowController.swift   main window + activation policy
    GuideWindowController.swift
    HotKey.swift             Carbon ⌥⌘R
    LoginItem.swift          SMAppService
```

## Things that will bite you

- **`RollField` must stay an `NSTextField`.** SwiftUI's `TextField` cannot
  select its contents on demand, and its focus is unreliable inside a
  non-activating panel. Both are core requirements: after every roll the field
  re-selects everything so a second Return re-rolls.
- **Return is handled twice on purpose** — `control(_:textView:doCommandBy:)`
  and a `target`/`action` fallback. The delegate path alone was observed not
  firing; if `doCommandBy` returns true the action isn't sent, so there's no
  double roll.
- **Colours must be dynamic `NSColor`s** (`NSColor.dynamic(light:dark:)`), not
  fixed `Color`s. Light and dark mode are separate designs. Never hardcode
  `Color.white.opacity(…)` for text — use `Theme.ink` / `inkStrong` / `inkMuted`
  / `inkFaint`, and `Theme.fill` / `hairline` for surfaces.
- **The panel closes on `windowDidResignKey`**, with a 0.4s grace period after
  showing, plus a global mouse-down monitor. Removing either breaks dismissal.
- **The status icon is drawn in `Theme.statusIcon()`.** `die.face.5` as an SF
  Symbol renders hairline-thin and undersized next to system icons.
- **Parser order matters.** Coin words → shuffle prefix → pick-n prefix → dice →
  date ranges → numeric ranges → lists → single number. Date ranges are tried at
  *every* separator position so ISO dates survive their own hyphens.

## Conventions

- UI strings are German, lowercase-ish and terse. Code and comments are English.
- Comments explain *why*, not *what*. Match the existing density — sparse.
- When adding an input form: extend `Parser.parse`, add the `Request` case and
  its `label`, handle it in `Roller.roll`, then add a row to `ANLEITUNG.md`,
  `GuideView.inputs`, `WindowView.syntax`, and the README table. All five.

## Not applicable here

No ports, no server, no `PORTS.md` entry — this is a desktop app.

import AppKit

// Headless mode: `QuickRNG --roll "2d6"` prints a result and exits.
// Handy from the terminal, and it's what the parser tests drive.
let args = Array(CommandLine.arguments.dropFirst())
if let flagIndex = args.firstIndex(where: { $0 == "--roll" || $0 == "-r" }) {
    let input = args.count > flagIndex + 1 ? args[flagIndex + 1] : ""
    guard let request = Parser.parse(input) else {
        FileHandle.standardError.write(Data("Kann \"\(input)\" nicht deuten.\n".utf8))
        exit(1)
    }
    let result = Roller.roll(request, input: input)
    print(result.primary)
    if args.contains("--verbose") {
        print("  \(request.label) — \(result.secondary ?? "")")
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)   // menu bar only until a window is opened
app.run()

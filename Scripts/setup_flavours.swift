#!/usr/bin/env swift
import Foundation

let root = FileManager.default.currentDirectoryPath
let scripts = "\(root)/Scripts"

let steps = [
    "generate_flavours.swift",
    "generate_xcconfigs.swift",
    "generate_flavour_strings.swift",
    "sync_selected_assets.swift"
]

func run(script: String) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["swift", "\(scripts)/\(script)"]
    process.currentDirectoryURL = URL(fileURLWithPath: root)

    print("\n🚀 Running \(script)...")
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw NSError(
            domain: "ScriptError",
            code: Int(process.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: "\(script) failed"]
        )
    }
}

do {
    print("🧩 Setting up flavours...\n")

    for step in steps {
        try run(script: step)
    }

    print("\n✅ All flavour setup steps completed successfully!")
} catch {
    print("\n❌ Error: \(error.localizedDescription)")
    exit(1)
}


#!/usr/bin/env swift
import Foundation

// =======================================================
// MODELS
// =======================================================

struct Flavour: Decodable {
    let id: String
    let targetName: String
    let bundleId: String
    let displayName: String
}

struct FlavoursData: Decodable {
    let flavours: [Flavour]
}

// =======================================================
// PATHS
// =======================================================

let root = FileManager.default.currentDirectoryPath
let flavoursFolder = "\(root)/Flavours"
let jsonPath = "\(root)/Scripts/flavours.json"

let fm = FileManager.default

// =======================================================
// LOAD JSON
// =======================================================

let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
let data = try JSONDecoder().decode(FlavoursData.self, from: jsonData)

print("🔧 Generating flavour folders & placeholders…")

// =======================================================
// GENERATION
// =======================================================

for f in data.flavours {

    let flavourDir = "\(flavoursFolder)/\(f.id)"
    let assetsDir = "\(flavourDir)/Assets.xcassets"
    let googlePlistPath = "\(flavourDir)/GoogleService-Info.plist"

    // Create flavour directory
    if !fm.fileExists(atPath: flavourDir) {
        try fm.createDirectory(atPath: flavourDir, withIntermediateDirectories: true)
        print("   ➕ Created \(flavourDir)")
    }

    // Create Assets.xcassets
    if !fm.fileExists(atPath: assetsDir) {
        try fm.createDirectory(atPath: assetsDir, withIntermediateDirectories: true)
        print("   ➕ Created Assets.xcassets for \(f.id)")
    }

    // Create EMPTY GoogleService-Info.plist (only if missing)
    if !fm.fileExists(atPath: googlePlistPath) {
        let emptyPlist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict/>
        </plist>
        """

        try emptyPlist.write(
            toFile: googlePlistPath,
            atomically: true,
            encoding: .utf8
        )

        print("   ➕ Created empty GoogleService-Info.plist for \(f.id)")
    } else {
        print("   ⚠️ GoogleService-Info.plist already exists for \(f.id)")
    }
}

print("✅ Flavour generation complete")


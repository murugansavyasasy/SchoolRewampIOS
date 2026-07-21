#!/usr/bin/env swift
import Foundation

// =======================================================
// PATHS (MATCH YOUR PROJECT STRUCTURE)
// =======================================================

// Script is run from project root
let root = FileManager.default.currentDirectoryPath

let jsonPath = "\(root)/Scripts/flavours.json"
let flavoursRoot = "\(root)/Flavours"

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
// LOAD JSON
// =======================================================

let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
let data = try JSONDecoder().decode(FlavoursData.self, from: jsonData)

let fm = FileManager.default

print("⚙️ Generating xcconfig files...")

// =======================================================
// GENERATE XCCONFIGS
// =======================================================

for flavour in data.flavours {

    let flavourDir = "\(flavoursRoot)/\(flavour.id)"
    let xcconfigPath = "\(flavourDir)/\(flavour.id).xcconfig"

    if !fm.fileExists(atPath: flavourDir) {
        try fm.createDirectory(atPath: flavourDir, withIntermediateDirectories: true)
        print("   ➕ Created directory \(flavourDir)")
    }

    let content = """
    // ======================================
    // AUTO-GENERATED — DO NOT EDIT
    // Source: Scripts/flavours.json
    // ======================================

    FLAVOUR_ID = \(flavour.id)
    PRODUCT_BUNDLE_IDENTIFIER = \(flavour.bundleId)
    APP_DISPLAY_NAME = \(flavour.displayName)
    """

    try content.write(
        toFile: xcconfigPath,
        atomically: true,
        encoding: .utf8
    )

    print("   ✔ Generated \(flavour.id).xcconfig")
}

print("🎉 xcconfig generation complete!")


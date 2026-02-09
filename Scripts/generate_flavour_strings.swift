#!/usr/bin/env swift
import Foundation

let root = FileManager.default.currentDirectoryPath
let jsonPath = "\(root)/Scripts/flavours.json"
let flavoursRoot = "\(root)/Flavours"

let fm = FileManager.default

// =======================================================
// MODELS
// =======================================================

struct FlavoursData: Decodable {
    let flavours: [Flavour]
}

struct Flavour: Decodable {
    let id: String
    let strings: [String: String]
}

// =======================================================
// LOAD JSON
// =======================================================

let data = try JSONDecoder().decode(
    FlavoursData.self,
    from: Data(contentsOf: URL(fileURLWithPath: jsonPath))
)

print("🧾 Generating flavour Localizable.strings…")

// =======================================================
// GENERATION
// =======================================================

for flavour in data.flavours {

    let flavourDir = "\(flavoursRoot)/\(flavour.id)"
    let filePath = "\(flavourDir)/Localizable.strings"

    try fm.createDirectory(
        atPath: flavourDir,
        withIntermediateDirectories: true
    )

    let content =
    """
    // ======================================
    // AUTO-GENERATED — DO NOT EDIT
    // Flavour: \(flavour.id)
    // ======================================

    \(flavour.strings
        .sorted(by: { $0.key < $1.key })
        .map { "\"\($0.key)\" = \"\($0.value)\";" }
        .joined(separator: "\n"))
    """

    try content.write(
        toFile: filePath,
        atomically: true,
        encoding: .utf8
    )

    print("   ✔ \(flavour.id)/Localizable.strings created")
}

print("✅ Flavour string generation complete")


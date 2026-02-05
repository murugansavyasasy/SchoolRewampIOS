#!/usr/bin/env swift
import Foundation

// =======================================================
// CONFIGURATION
// =======================================================

let selected = [
    "AppIcon",
    "BackGroundClr",
    "PrimeryColor",
    "splashLight1",
    "splashLight2",
    "school 2",
    "school_chimes 2"
]

// BASE assets (SOURCE)
let root = FileManager.default.currentDirectoryPath
let basePath = "\(root)/VsSchoolChimes/BaseAssets.xcassets"

// Flavours (DESTINATION)
let flavoursRoot = "\(root)/Flavours"

// =======================================================
// IMPLEMENTATION
// =======================================================

let fm = FileManager.default

func findAsset(named name: String, in basePath: String) -> String? {
    let enumerator = fm.enumerator(atPath: basePath)

    while let item = enumerator?.nextObject() as? String {
        if item.hasSuffix("\(name).colorset") ||
           item.hasSuffix("\(name).imageset") ||
           item.hasSuffix("\(name).appiconset") {
            return basePath + "/" + item
        }
    }
    return nil
}

let flavours = try fm.contentsOfDirectory(atPath: flavoursRoot).filter {
    var isDir: ObjCBool = false
    let full = "\(flavoursRoot)/\($0)"
    return fm.fileExists(atPath: full, isDirectory: &isDir) && isDir.boolValue
}

print("🔄 Copying selected override assets…")

for flavour in flavours {

    print("\n➡️ Flavour: \(flavour)")
    let destAssetsPath = "\(flavoursRoot)/\(flavour)/Assets.xcassets"

    for assetName in selected {

        guard let src = findAsset(named: assetName, in: basePath) else {
            print("   ❌ Asset not found: \(assetName)")
            continue
        }

        let relativePath = src.replacingOccurrences(of: basePath + "/", with: "")
        let dst = "\(destAssetsPath)/\(relativePath)"
        let dstDir = (dst as NSString).deletingLastPathComponent

        try? fm.createDirectory(
            atPath: dstDir,
            withIntermediateDirectories: true
        )

        if fm.fileExists(atPath: dst) {
            print("   ⚠️ Skipped (exists): \(relativePath)")
        } else {
            try fm.copyItem(atPath: src, toPath: dst)
            print("   ✔ Copied \(relativePath)")
        }
    }
}

print("🎉 Selected assets synced!")

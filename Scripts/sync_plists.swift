#!/usr/bin/env swift
import Foundation

let root = FileManager.default.currentDirectoryPath

let basePlist = "\(root)/School Chimes/Info.plist"
let flavoursRoot = "\(root)/Flavours"

let fm = FileManager.default

func load(_ path: String) -> NSMutableDictionary {
    let data = fm.contents(atPath: path)!
    return try! PropertyListSerialization.propertyList(
        from: data,
        options: .mutableContainers,
        format: nil
    ) as! NSMutableDictionary
}

let flavourFolders = try! fm.contentsOfDirectory(atPath: flavoursRoot).filter {
    var isDir: ObjCBool = false
    let full = "\(flavoursRoot)/\($0)"
    return fm.fileExists(atPath: full, isDirectory: &isDir) && isDir.boolValue
}

print("🔄 Syncing Info.plist files…")

for id in flavourFolders {

    let plistPath = "\(flavoursRoot)/\(id)/Info.plist"

    if !fm.fileExists(atPath: plistPath) {
        try! fm.copyItem(atPath: basePlist, toPath: plistPath)
        print("   ➕ Created Info.plist for \(id)")
        continue
    }

    let baseDict = load(basePlist)
    let targetDict = load(plistPath)

    baseDict.forEach { key, value in
        if targetDict[key] == nil {
            targetDict[key] = value
        }
    }

    let out = try! PropertyListSerialization.data(
        fromPropertyList: targetDict,
        format: .xml,
        options: 0
    )
    try! out.write(to: URL(fileURLWithPath: plistPath))

    print("   ✔ Synced Info.plist for \(id)")
}

print("🎉 All Info.plists synced!")


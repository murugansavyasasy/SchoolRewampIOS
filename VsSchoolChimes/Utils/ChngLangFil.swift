////
////  ChngLangFil.swift
////  VsSchoolChimes
////
////  Created by admin on 09/11/24.
////
//
//
//import Foundation
//
//private var bundleKey: UInt8 = 0
//
//extension Bundle {
//    static let localizedBundle: Bundle = {
//        object_setClass(Bundle.main, type(of: BundleOverride()))
//        return Bundle.main
//    }()
//    
//    @objc var localizedBundle: Bundle {
//        get {
//            objc_getAssociatedObject(self, &bundleKey) as? Bundle ?? Bundle.main
//        }
//        set {
//            objc_setAssociatedObject(self, &bundleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//    
//    private class BundleOverride: Bundle {
//        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
//            return localizedBundle.localizedString(forKey: key, value: value, table: tableName)
//        }
//    }
//    
//    static func setLanguage(_ language: String) {
//        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? ""), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//    }
//}
//

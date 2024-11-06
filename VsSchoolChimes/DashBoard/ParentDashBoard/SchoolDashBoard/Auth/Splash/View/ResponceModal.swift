//
//  ResponceModal.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import Foundation



import Foundation

struct RequestBody: Codable {
    
    let CountryID : Int!
    let DeviceType : String!
    let MobileNumber : String!
    let Password : String!
    let SecureID : String!
}

struct LoginResponseData: Codable {
    let status: String
    let message: String
    let staffRole: String
    let staffDisplayRole: String
    let isParent: Bool
    let isStaff: Bool
    let staffDetails: [StaffDetail]
    let childDetails: [ChildDetail]

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case staffRole = "staff_role"
        case staffDisplayRole = "staff_display_role"
        case isParent = "is_parent"
        case isStaff = "is_staff"
        case staffDetails = "StaffDetails"
        case childDetails = "ChildDetails"
    }
}

struct StaffDetail: Codable {
    let staffID: String
    let staffName: String
    let schoolID: String
    let schoolName: String
    let schoolNameRegional: String?
    let schoolAddress: String
    let city: String?
    let schoolLogo: String
    let isBooksEnabled: Int
    let onlineBooksLink: String
    let role: String
    let isPaymentPending: String
    let schoolType: Int
    let biometricEnable: Int

    enum CodingKeys: String, CodingKey {
        case staffID = "StaffID"
        case staffName = "StaffName"
        case schoolID = "SchoolID"
        case schoolName = "SchoolName"
        case schoolNameRegional = "SchoolNameRegional"
        case schoolAddress = "SchoolAddress"
        case city = "city"
        case schoolLogo = "SchoolLogo"
        case isBooksEnabled = "isBooksEnabled"
        case onlineBooksLink = "OnlineBooksLink"
        case role = "role"
        case isPaymentPending = "is_payment_pending"
        case schoolType = "school_type"
        case biometricEnable = "biometricEnable"
    }
}

struct ChildDetail: Codable {
    let childID: String
    let childName: String
    let standardName: String
    let sectionName: String
    let schoolID: String
    let schoolName: String
    let schoolNameRegional: String?
    let schoolCity: String
    let schoolLogoUrl: String
    let rollNumber: String
    let isNotAllow: String
    let displayMessage: String
    let isBooksEnabled: Int
    let onlineBooksLink: String
    let classID: Int
    let sectionID: Int

    enum CodingKeys: String, CodingKey {
        case childID = "ChildID"
        case childName = "ChildName"
        case standardName = "StandardName"
        case sectionName = "SectionName"
        case schoolID = "SchoolID"
        case schoolName = "SchoolName"
        case schoolNameRegional = "SchoolNameRegional"
        case schoolCity = "SchoolCity"
        case schoolLogoUrl = "SchoolLogoUrl"
        case rollNumber = "RollNumber"
        case isNotAllow = "IsNotAllow"
        case displayMessage = "DisplayMessage"
        case isBooksEnabled = "isBooksEnabled"
        case onlineBooksLink = "OnlineBooksLink"
        case classID = "classId"
        case sectionID = "sectionId"
    }
}

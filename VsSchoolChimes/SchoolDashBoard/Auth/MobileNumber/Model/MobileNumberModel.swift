//
//  MobileNumberModel.swift
//  VsSchoolChimes
//
//  Created by admin on 13/06/24.
//

import Foundation


class MobileNumberModel         : Codable{
    var MobileNumber            : String!
    var DeviceType              : String!
    var SecureID                : String!
    var Password                : String!
}


class MobileNumberResponse      : Codable{
    var isNumberExists          : String!
    var isPasswordUpdated       : Int!
    var redirect_to_otp         : String!
    var Message                 : String!
    var Status                  : String!
    var MoreInfo                : String!
}

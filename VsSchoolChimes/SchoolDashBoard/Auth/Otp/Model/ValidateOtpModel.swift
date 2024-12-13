//
//  ValidateOtpModel.swift
//  VsSchoolChimes
//
//  Created by admin on 13/06/24.
//

import Foundation

class ValidateOtpModel     : Codable{
    var OTP                : String!
    var MobileNumber       : String!
}


class ValidateOtpResponse  : Codable{
    var Message            : String!
    var Status             : String!
}

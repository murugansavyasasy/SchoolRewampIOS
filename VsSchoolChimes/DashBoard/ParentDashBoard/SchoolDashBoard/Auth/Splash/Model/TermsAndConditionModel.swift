//
//  TermsAndConditionModal.swift
//  VsSchoolChimes
//
//  Created by admin on 13/06/24.
//

import Foundation

class TermsAndConditionModel        : Codable{
    var SecureID                    : String!
    var OtherDetails                : String!
    var isAgreed                    : String!
}

class TermsAndConditionResponse     : Codable{
    var Status                      : Int!
    var Message                     : String!
}

//
//  CountryListModal.swift
//  VsSchoolChimes
//
//  Created by admin on 13/06/24.
//

import Foundation


class CountryListModel          : Codable{
    var AppID                   : String!
    var DeviceType              : String!
    var CountryCode             : String!
    
}


class CountryListResponse       : Codable{
    var CountryID               : String!
    var CountryName             : String!
    var CountryCode             : String!
    var BaseUrl                 : String!
    var MobileNumberLength      : String!
    var ResendOTPTimer          : String!
    
    
}

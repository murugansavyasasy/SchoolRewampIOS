//
//  Model.swift
//  rghs
//
//  Created by admin on 17/01/25.
//

import Foundation

struct VersionRespons:Codable{
    let status : Bool?
    let message : String?
    let data : [SuccsessData]
    let count : Int?
    let token : String?
}

struct SuccsessData:Codable{
    let is_update_available : Bool?
    let is_force_update_available : Bool?
    let version_id : String?
    let help : String?
    let data_production : String?
    let terms_and_condition : String?
    let about_us : String?
    let redirect_url : String?
    
}

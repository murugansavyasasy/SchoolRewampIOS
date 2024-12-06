//
//  punchResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 31/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class punchModal : Mappable{
    
    var user_id : Int!
    var staff_or_student : String!
    var institute_id : Int!
   
    var  device_id : String!
    var punch_type : Int!
    var device_model : String!


    init(){}
   
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        user_id <- map["user_id"]
        staff_or_student <- map["staff_or_student"]
        institute_id <- map["institute_id"]
        device_model <- map["device_model"]
        punch_type <- map["punch_type"]
        device_id <- map["device_id"]
    }

}
class punchResponce : Mappable{
    
    var status : Int!
    var message : String!
    
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        status <- map["status"]
        message <- map["message"]
    }
    
    
}

//
//  DeleteResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 09/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class deleteModal : Mappable{
   
    
    var instituteId : Int!
    var locationId : Int!
    init(){}
    

    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        instituteId <- map["instituteId"]
        locationId <- map["locationId"]
    }
    
    
}
class deletResponce : Mappable {
   
    
    
    var  status : Int!
    var message : String!

    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        status <- map ["status"]
        message <- map ["message"]
    }
}

//
//  locationResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class AddloactionModal : Mappable{
    
    var instituteId : Int!
    var userId : Int!
    var location : String!
    var longitude : String!
    var latitude : String!
    var distance : Int!
   
    init(){}
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        instituteId <- map["instituteId"]
        userId <- map["userId"]
        location <- map["location"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        distance <- map["distance"]
        
        
    }
    
 
}


class addlocationResps : Mappable{
    
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

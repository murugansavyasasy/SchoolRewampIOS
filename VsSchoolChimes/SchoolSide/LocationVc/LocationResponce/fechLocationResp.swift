//
//  fechLocationResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 03/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class fechModal : Mappable{
    
    var status : Int!
    var message : String!
    var data : [FechdataDetails]!
    
     
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
        
    }
 
    
}
class FechdataDetails : Mappable{
    
    var latitude : String!
    var longitude : String!
    var location : String!
    var distance : String!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        location <- map["location"]
        distance <- map["distance"]
    }
 
    
}

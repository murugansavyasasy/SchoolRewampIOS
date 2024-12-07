//
//  deleteResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 02/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class getLatModel : Mappable{
   
    
    
    var status : Int!
    var message : String!
    var data : [GetLatModaldataDetails]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
    
        
}


class GetLatModaldataDetails : Mappable{
    
    var id : Int!
    var latitude : String!
    var longitude : String!
    var location : String!
    var distance : String!
   
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        location <- map["location"]
        distance <- map["distance"]
    }
    
 
}




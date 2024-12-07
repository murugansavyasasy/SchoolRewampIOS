//
//  EditLocResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 25/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class EditLocModal : Mappable{
  
    
    
    var id : Int!
    var location : String!
    var distance : String!
    var userId : Int!

    init(){}
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        location <- map["location"]
        distance <- map["distance"]
        userId <- map["userId"]
    }
    
    
}
class EditLocResponce : Mappable{
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

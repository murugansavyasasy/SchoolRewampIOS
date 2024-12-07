//
//  StaffListResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class staffListModal : Mappable{
    
    
    var status : Int!
    var message : String!
    var data : [ModaldataDetails]!
    
    
    
    
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        message <- map["message"]
        status <- map["status"]
        data <- map["data"]
        
    }
    
    
    
}
class ModaldataDetails : Mappable{
    
    
    var staffId : Int!
    var staffName : String!
    
   
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        
        staffId <- map["staffId"]
        staffName <- map["staffName"]
        
    }
 
}

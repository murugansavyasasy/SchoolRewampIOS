//
//  CountResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class CountReqModal: Mappable {
    var staffId: String!
    var SchoolID: String!
    var ID : String!
    var Types : String!
    init(){}
    required init?(map: Map) {
        // Initialization here, if needed
    }
    
    func mapping(map: Map) {
        staffId <- map["staffId"]
        SchoolID <- map["SchoolID"]
        ID <- map["ID"]
        Types <- map["Type"]
    }
}



class countResponce : Mappable{
    
    var SCHOOLID : String!
    var OVERALLCOUNT : String!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        SCHOOLID <- map["SCHOOLID"]
        OVERALLCOUNT <- map["OVERALLCOUNT"]
    }
 
}




class VideocountResponce : Mappable{
    
    var SCHOOLID : String!
    var OVERALLCOUNT : String!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        SCHOOLID <- map["SCHOOLID"]
        OVERALLCOUNT <- map["OVERALLCOUNT"]
    }
 
}

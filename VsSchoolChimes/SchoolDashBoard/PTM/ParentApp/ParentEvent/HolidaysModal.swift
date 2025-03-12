//
//  HolidaysModal.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 31/05/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class HolidaysModal : Mappable {
    
  

    var memberid : String!
    var schoolid : String!
    
    init(){}
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        memberid <- map["memberid"]
        schoolid <- map["schoolid"]
       
        
    }
    
    
    
    
    
}


class HolidaysRes : Mappable {
    
    

    var status : Int!
    var message : String!
    var holidayData   : [HolidayDataRes]!
    
    init(){}
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        status <- map["status"]
        message <- map["message"]
        holidayData<-map["data"]
        
    }
    
    
    
    
    
}

class HolidayDataRes : Mappable{
  
    
    
      var holiday_year : String!
      var holiday_date : String!
      var holiday_name : String!
       
    required init?(map: ObjectMapper.Map) {
     
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        holiday_year <- map["holiday_year"]
        holiday_date <- map["holiday_date"]
        holiday_name <- map["holiday_name"]
    }

}



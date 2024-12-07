//
//  slotValidation.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper





    
    
    

class ValidationforStaffModal : Mappable{
    
    var event_link : String!
    var institute_id : Int!
    var staff_id : Int!
    var break_time : Int!
    var date  : String!
    var duration :Int!
    var event_name : String!
    var from_time : String!
    var to_time :String!
    var meeting_mode : String!
    var slots : [slotDataDetails]!
    var std_sec_details : [sectionDataDetails]!
    
    init(){}
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        institute_id <- map["institute_id"]
        staff_id <- map["staff_id"]
        break_time <- map["break_time"]
        date <- map["date"]
        duration <- map["duration"]
        event_name <- map["event_name"]
        from_time <- map["from_time"]
        to_time <- map["to_time"]
        meeting_mode <- map["meeting_mode"]
        slots <- map["slots"]
        std_sec_details <- map["std_sec_details"]
        event_link <- map["event_link"]
        
    }
    
    
    
    
    
}


class slotDataDetails : Mappable{
    
    var from_time : String!
    var to_time : String!
    var slot_Availablity : String!
    init(){}
   
    required init?(map: ObjectMapper.Map) {
        
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        
        to_time <- map["to_time"]
        from_time <- map["from_time"]
        slot_Availablity <- map["slot_Availablity"]
    }
    
    
    
    
    
}

class sectionDataDetails : Mappable{
    
  
    var class_id : Int!
    var section_id : Int!
    init(){}
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        section_id <- map["section_id"]
        class_id <- map["class_id"]
    }
 
}

class  aviableSlotResponce : Mappable{
    
    var Status : Int!
    var Message : String!
    var data : [RespDataDetails]!
  
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        Status <- map["Status"]
        Message <- map["Message"]
        data <- map["data"]
    }

}
class RespDataDetails : Mappable{
    var date : String!
    var slots : [slotDataDetails]!
    var std_sec_details : [sectionDataDetails]!
  
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        date <- map["date"]
        slots <- map["slots"]
        std_sec_details <- map ["std_sec_details"]
    }
    
    
    
    
}

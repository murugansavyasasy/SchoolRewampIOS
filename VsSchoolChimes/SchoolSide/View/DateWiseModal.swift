//
//  DateWiseModal.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 19/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class SlotDetailsModals: Mappable {
   
    
    var eventDate: String!
    var staffId: Int!
    var instituteId: Int!
    // Add other properties based on the JSON structure
    init(){}
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
        eventDate    <- map["event_date"]
        staffId      <- map["staff_id"]
        instituteId  <- map["institute_id"]
        // Map other properties
    }
}

class DateWiseModals : Mappable{
    
    var Status  : Int!
    var Message : String!
    var data  : [DateWiseModalDataDetails]!
  
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        Status <- map["Status"]
        Message <- map["Message"]
        data <- map["data"]
        
    }
    
    
    
}


class DateWiseModalDataDetails : Mappable{
    

    
    var date : String!
    var eventDate : String!
    var slotId : Int!
    var slotFrom : String!
    var slotTo : String!
    var eventName : String!
    var eventMode :  String!
    var eventLink :  String!
    var studentId : Int!
    var studentName : String!
    var  classId: Int!
    var sectionId : Int!
    var className :  String!
    var sectionName :  String!
    var slotStatus : String!
    var isBooked : Int!

    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        date <- map["date"]
        slotId <- map["slotId"]
        slotFrom <- map["slotFrom"]
        slotTo <- map["slotTo"]
        eventName <- map["eventName"]
        eventMode <- map["eventMode"]
        eventLink <- map["eventLink"]
        studentId <- map["studentId"]
        studentName <- map["studentName"]
        classId <- map["classId"]
        sectionId <- map["sectionId"]
        className <- map["className"]
        sectionName <- map["sectionName"]
        slotStatus <- map["slotStatus"]
        isBooked <- map["isBooked"]
        eventDate <- map["eventDate"]
        
    }
    
    
    
    
    
}

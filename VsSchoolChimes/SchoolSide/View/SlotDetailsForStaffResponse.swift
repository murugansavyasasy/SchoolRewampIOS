//
//  SlotDetailsForStaffResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation

import ObjectMapper





class SlotDetailsForStaffResponse     : Mappable {

    var Status                                       : Int!
    var Message                                      : String!
    var data                                         : [SlotDetailsForStaffData]!


    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map) {
        Status                                           <- map["Status"]
        Message                                          <- map["Message"]
        data                                             <- map["data"]

    }

}
class SlotDetailsForStaffData     : Mappable {

    var date                                      : String!
    var details                                         : [SlotDetails]!


    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map) {
        date                                          <- map["date"]
        details                                             <- map["details"]

    }

}

class SlotDetails         : Mappable {




    var event_name                                    : String!
    var event_mode                                      : String!
    var meeting_duration                                    : Int!
    var break_duration                                     : Int!
    var slots                                   : [SlotLists]!

    var std_sec_details  :   [sectionDetails]!


    required init?(map: ObjectMapper.Map)            {
        mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map)              {


        event_name                                          <- map["event_name"]
        event_mode                                          <- map["event_mode"]
        meeting_duration                                    <- map["meeting_duration"]
        break_duration                                      <- map["break_duration"]
        slots                                               <- map["slots"]
        std_sec_details                                     <- map["std_sec_details"]




    }
}





class SlotLists         : Mappable {



    var slot_id                                    : String!
    var from_time                                  : String!
    var to_time                                    : String!
    var is_cancelled                               : Int!
    var is_booked                                  : Int!
    var booked_by                                  : String!
    var my_class                                   : String!
    var my_section                                 : String!
    var status                                     : String!
    var event_name : String!
    var event_mode      : String!
    var profile_url : String!
    var date : String!






    required init?(map: ObjectMapper.Map)            {
        mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map)              {
        slot_id                                          <- map["slot_id"]
        from_time                                        <- map["from_time"]
        to_time                                          <- map["to_time"]
        is_cancelled                                     <- map["is_cancelled"]
        is_booked                                        <- map["is_booked"]
        booked_by                                        <- map["booked_by"]
        my_class                                         <- map["my_class"]
        my_section                                       <- map["my_section"]
        status                                           <- map["status"]
        event_name                                       <- map["event_name"]
        event_mode                                       <- map["event_mode"]
        profile_url                                     <- map["profile_url"]
        date                                     <- map["date"]



    }
}



class sectionDetails : Mappable{


    var  class_id : String!
    var  section_id : String!
    var class_name : String!
    var section_name : String!


    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map) {
        class_id                                        <- map["class_id"]
        section_id                                      <- map["section_id"]
        class_name                                      <- map["class_name"]
        section_name                                    <- map["section_name"]
    }
}









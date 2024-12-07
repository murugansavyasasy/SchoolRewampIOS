//
//  CreateSlotsByStaffModal.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class CreateSlotsByStaffModal           : Mappable {

    var institute_id                    : Int!
    var date                            : String!
    var staff_id                        : Int!
    var break_time                      : Int!
    var duration                        : Int!
    var event_name                      : String!
    var from_time                       : String!
    var to_time                         : String!
    var meeting_mode                    : String!
    var event_link                      : String!
    var slots                           : [CreateSlotList]!
    var std_sec_details                 : [CreateStdSecDetails]!

    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    institute_id                        <- map["institute_id"]
    date                                <- map["date"]
    staff_id                            <- map["staff_id"]
    break_time                          <- map["break_time"]
    duration                            <- map["duration"]
    event_name                          <- map["event_name"]
    from_time                           <- map["from_time"]
    to_time                             <- map["to_time"]
    meeting_mode                        <- map["meeting_mode"]
    event_link                          <- map["event_link"]
    slots                               <- map["slots"]
    std_sec_details                                        <- map["std_sec_details"]

}
}




class CreateSlotList     : Mappable {

var from_time                                       : String!
var to_time                                      : String!

    init(){}
required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
    from_time                                           <- map["from_time"]
    to_time                                          <- map["to_time"]

}

}



class CreateStdSecDetails     : Mappable {

var class_id                                       : Int!
var section_id                                      : Int!
    init(){}

required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
    class_id                                           <- map["class_id"]
    section_id                                          <- map["section_id"]

}

}





class CreateSlotsByStaffResponse     : Mappable {

var Status                                       : Int!
var Message                                      : String!


required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
Status                                           <- map["Status"]
Message                                          <- map["Message"]

}

}


//
//  TeacherWiseSlotAvailabilityResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 12/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper



class GetTeacherwiseSlotAvailabilityResponse     : Mappable {

var Status                                       : Int!
var Message                                      : String!
var data                                         : [GetTeacherwiseSlotAvailabilityData]!


required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
Status                                           <- map["Status"]
Message                                          <- map["Message"]
data                                             <- map["data"]

}

}

class GetTeacherwiseSlotAvailabilityData         : Mappable {

var slot_id                                      : Int!
var from_time                                    : String!
var to_time                                      : String!
var is_booked                                    : Int!
var staff_id                                     : Int!
var staff_name                                   : String!
var subject_name                                 : String!
var event_name                                    : String!
var event_mode                                      : String!
var event_link                                    : String!
var my_booking                                      :Int!



required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    slot_id                                          <- map["slot_id"]
    from_time                                        <- map["from_time"]
    to_time                                          <- map["to_time"]
    is_booked                                        <- map["is_booked"]
staff_id                                         <- map["staff_id"]
staff_name                                       <- map["staff_name"]
subject_name                                     <- map["subject_name"]
    event_name                                          <- map["event_name"]
    event_mode                                        <- map["event_mode"]
    event_link                                          <- map["event_link"]
    my_booking                                        <- map["my_booking"]




}
}










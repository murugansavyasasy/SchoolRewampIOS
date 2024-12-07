//
//  SlotHistoryForParentResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 12/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation

import ObjectMapper





    class SlotHistoryForParentResponse     : Mappable {

    var Status                                       : Int!
    var Message                                      : String!
    var data                                         : [SlotHistoryForParentResponseData]!


    required init?(map: ObjectMapper.Map) {
    mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map) {
    Status                                           <- map["Status"]
    Message                                          <- map["Message"]
    data                                             <- map["data"]

    }

    }

    class SlotHistoryForParentResponseData         : Mappable {

        var slot_id                                      : String!
        var slot_date                                    : String!
        var slot_time                                      : String!
        var status                                    : String!

    var purpose                                     : String!
    var mode                                   : String!
    var event_link                                 : String!
    var staff_id                                        : String!
        var staff_name                                      : String!
        var subject_name                                    : String!
        var my_booking                                      :String!



    required init?(map: ObjectMapper.Map)            {
    mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map)              {
        slot_id                                          <- map["slot_id"]
        slot_date                                        <- map["slot_date"]
        slot_time                                          <- map["slot_time"]
        status                                        <- map["status"]
        purpose                                         <- map["purpose"]
        mode                                       <- map["mode"]
        event_link                                     <- map["event_link"]
        staff_id                                          <- map["staff_id"]
        staff_name                                        <- map["staff_name"]
        subject_name                                          <- map["subject_name"]




    }
    }










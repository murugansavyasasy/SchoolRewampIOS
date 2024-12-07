//
//  CancelSlotResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 12/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class CancelSlotsForStudModal   : Mappable {
    var staff_id : Int!
    var student_id                                      : Int!
    var slot_id                                    : Int!
    var cancelled_reason                                    : String!
    var institute_id                                    : Int!

    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    student_id                                          <- map["student_id"]
    slot_id                                        <- map["slot_id"]
    cancelled_reason                                        <- map["cancelled_reason"]
    institute_id                                        <- map["institute_id"]
    staff_id <- map["staff_id"]

}
}






class CancelSlotsForStudentsResponse     : Mappable {

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

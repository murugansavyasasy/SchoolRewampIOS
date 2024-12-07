//
//  CancelAndCloseSlotByStaffModal.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation

import ObjectMapper



class CancelAndCloseSlotByStaffModal   : Mappable {

    var staff_id                                      : Int!
    var slot_id                                    : Int!
    var institute_id                                    : Int!

    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    staff_id                                          <- map["staff_id"]
    slot_id                                        <- map["slot_id"]
    institute_id                                        <- map["institute_id"]


}
}





class CancelAndCloseSlotByStaffResponse     : Mappable {

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

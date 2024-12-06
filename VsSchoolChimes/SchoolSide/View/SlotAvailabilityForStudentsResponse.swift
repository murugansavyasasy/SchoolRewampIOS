//
//  SlotAvailabilityForStudentsResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 12/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class SlotAvailabilityForStudentsResponse     : Mappable {

var Status                                       : Int!
var Message                                      : String!
var data                                         : [SlotAvailabilityForStudentsData]!


required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
Status                                           <- map["Status"]
Message                                          <- map["Message"]
data                                             <- map["data"]

}

}

class SlotAvailabilityForStudentsData         : Mappable {

    var eventDate                                      : String!
    var count                                    : String!



required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    eventDate                                          <- map["eventDate"]
    count                                        <- map["count"]


}
}



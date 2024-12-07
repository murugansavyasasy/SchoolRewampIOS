//
//  StandardSectionDetailsForStaffResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper



class StandardSectionDetailsForStaffResponse     : Mappable {

    var Status                                       : Int!
    var Message                                      : String!
    var data                                         : [StandardSectionDetailsForStaffData]!


    required init?(map: ObjectMapper.Map) {
    mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map) {
    Status                                           <- map["Status"]
    Message                                          <- map["Message"]
    data                                             <- map["data"]

    }

    }

    class StandardSectionDetailsForStaffData         : Mappable {



        var class_id                                      : Int!
        var section_id                                    : Int!
        var class_name                                      : String!
        var section_name                                    : String!




    required init?(map: ObjectMapper.Map)            {
    mapping(map: map)
    }

    func mapping(map: ObjectMapper.Map)              {
        class_id                                          <- map["class_id"]
        section_id                                        <- map["section_id"]
        class_name                                          <- map["class_name"]
        section_name                                        <- map["section_name"]



    }
    }


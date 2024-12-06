//
//  RestrictionModal.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/27/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class RestrictionResponse                  : Mappable {
    var result                             : Int!
    var Message                            : String!
    var Content                            : String!
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    result                                 <- map["result"]
    Message                                <- map["Message"]
    Content                                <- map["Content"]
   

}
}



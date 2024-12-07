//
//  SubjectListForStudentResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 16/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class SubjectListForStudentResponse     : Mappable {

var Status                                       : Int!
var Message                                      : String!
var data                                         : [SubjectListForStudentData]!


required init?(map: ObjectMapper.Map) {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map) {
Status                                           <- map["Status"]
Message                                          <- map["Message"]
data                                             <- map["data"]

}

}

class SubjectListForStudentData         : Mappable {


    var subjectName                                      : String!
    var subjectId                                    : Int!
    var classTeacherId                                    : Int!



required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    subjectName                                          <- map["subjectName"]
    subjectId                                        <- map["subjectId"]
    classTeacherId                                        <- map["classTeacherId"]


}
}



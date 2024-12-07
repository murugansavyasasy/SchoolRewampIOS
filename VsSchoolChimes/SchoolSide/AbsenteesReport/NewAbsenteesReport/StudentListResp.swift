//
//  StudentListResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class studentListModal : Mappable{
    var schoolId : String!
    var sectionId : String!
    var absentOn : String!
    
    init(){}
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        schoolId <- map["schoolId"]
        sectionId <- map["sectionId"]
        absentOn <- map["absentOn"]
    }
    
    
    
}


class studentListResponce : Mappable{
    var Status : Int!
    var Message : String!
    var data : [StudentDataDetails]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        Status <- map["Status"]
        Message <- map["Message"]
        data <- map["data"]
    }
}

class  StudentDataDetails : Mappable{
    var studentName : String!
    var studentId : Int!
    var admissionNo : String!
    var rollNo  : String!
    var primaryMobile : String!
    var photoPath : String!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        studentName <- map["studentName"]
        studentId <- map["studentId"]
        admissionNo <- map["admissionNo"]
        rollNo <- map["rollNo"]
        primaryMobile <- map["primaryMobile"]
        photoPath <- map["photoPath"]
    }
    
    
    
    
}



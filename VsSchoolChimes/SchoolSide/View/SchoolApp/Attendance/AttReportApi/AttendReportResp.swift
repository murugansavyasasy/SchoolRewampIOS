//
//  AttendReportResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//


import Foundation
import ObjectMapper
class StudentAttendenceReportResponse : Mappable{
    
    var status : Int!
    var message : String!
    var data : [reasondetails]!
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
    
}

class reasondetails : Mappable{
    var student_name : String!
    var admission_no: String!
    var att_status: String!
    var absent_on: String!
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        student_name <- map["student_name"]
        admission_no <- map["admission_no"]
        att_status <- map["att_status"]
        absent_on <- map["absent_on"]
    }
    
    
}

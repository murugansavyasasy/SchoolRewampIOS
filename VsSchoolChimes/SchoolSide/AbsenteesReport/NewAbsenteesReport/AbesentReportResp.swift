//
//  AbesentReportResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 25/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class abesentModal : Mappable{
    var SchoolId : String!
    init(){}
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        SchoolId<-map["SchoolId"]
    }
    
    
    
    
    
}
class abesentResponce : Mappable{
    var Date : String!
    var Day  : String!
    var absentdateonly : String!
    var TotalAbsentees : String!
    var ClassWise : [ClassWisDataDetails]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        Date<-map["Date"]
        Day<-map["Day"]
        absentdateonly<-map["absentdateonly"]
        TotalAbsentees<-map["TotalAbsentees"]
        ClassWise<-map["ClassWise"]
    }
    
    
    
}

class ClassWisDataDetails : Mappable{
    var  ClassName : String!
    var ClassId : String!
    var TotalAbsentees : String!
    var SectionWise :  [SectionWiseDatadetails]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        ClassName<-map["ClassName"]
        ClassId<-map["ClassId"]
        TotalAbsentees<-map["TotalAbsentees"]
        SectionWise<-map["SectionWise"]
    }
    
}

class SectionWiseDatadetails : Mappable{
    var SectionName : String!
    var SectionId : String!
    var TotalAbsentees : String!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        SectionName<-map["SectionName"]
        SectionId<-map["SectionId"]
        TotalAbsentees<-map["TotalAbsentees"]
    }
    
}

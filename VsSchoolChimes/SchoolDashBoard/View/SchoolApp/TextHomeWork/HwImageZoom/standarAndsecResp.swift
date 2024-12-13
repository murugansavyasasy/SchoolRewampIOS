//
//  standarAndsecResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 05/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class Sectionresquest : Mappable{
    
    var SchoolId : Int!
    var StaffID : Int!
    var COUNTRY_CODE : String!
    init(){}
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        SchoolId <- map["SchoolId"]
        StaffID <- map["StaffID"]
        COUNTRY_CODE <- map["COUNTRY_CODE"]
    }
 
}




class Section: Mappable {
    var sectionId: Int!
    var mSectionId: Int!
    var sectionName: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        sectionId    <- map["SectionId"]
        mSectionId   <- map["mSectionId"]
        sectionName  <- map["SectionName"]
    }
}

// MARK: - Subject Model
class Subject: Mappable {
    var subjectId: Int!
    var subjectName: String!

    required init?(map: Map) {}

    func mapping(map: Map) {
        subjectId    <- map["SubjectId"]
        subjectName  <- map["SubjectName"]
    }
}

// MARK: - StandardData Model
class StandardData: Mappable {
    var standardId: Int!
    var standardLevelId: Int!
    var standard: String!
    var sections: [Section]!
    var subjects: [Subject]!

    required init?(map: Map) {}

    func mapping(map: Map) {
        standardId       <- map["StandardId"]
        standardLevelId  <- map["standardLevelId"]
        standard         <- map["Standard"]
        sections         <- map["Sections"]
        subjects         <- map["Subjects"]
    }
}

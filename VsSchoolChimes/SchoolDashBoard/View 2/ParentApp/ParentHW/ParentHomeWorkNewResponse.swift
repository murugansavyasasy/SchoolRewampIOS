//
//  ParentHomeWorkNewResponse.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class ParentHomeWorkArchiveModal : Mappable {
    
    
    var SchoolID : String!
    var ChildID : String!
    
    
    
    init(){}
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        ChildID <- map["ChildID"]
        SchoolID <- map["SchoolID"]
        
    }
    
}


class ParentHomeWorkArchiveResponse : Mappable {
    
    
    
    var Status : String!
    var Message : String!
    var homeWorkArchiveData : [HomeWorkArchiveDataList]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        Status <- map["Status"]
        Message <- map["Message"]
        homeWorkArchiveData <- map["data"]
    }
    
}
class HomeWorkArchiveDataList : Mappable {
    
    var date : String!
    
    var hwData : [HWDataList]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        date <- map["date"]
        hwData <- map["hw"]
    }
    
    
    
}
class HWDataList : Mappable {
    
    var subjectname : String!
    
    var topic : String!
    
    var content : String!
    var filepath : [HWFilePath]!
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        subjectname <- map["subjectname"]
        topic <- map["topic"]
        content <- map["content"]
        filepath <- map["filepath"]
    }
    
}


class HWFilePath : Mappable {
    
    var path : String!
    
    var type : String!
    
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        path <- map["path"]
        type <- map["type"]
        
    }
    
}

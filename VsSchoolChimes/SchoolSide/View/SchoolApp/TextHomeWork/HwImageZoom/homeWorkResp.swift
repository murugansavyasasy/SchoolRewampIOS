//
//  homeWorkResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class homeWorkRespo : Mappable{
    
    
    var status : Int!
    var message : String!
    var data : [HomeworkDataDetails]!
    
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }

}


class HomeworkDataDetails : Mappable{
    
    var homeworktopic : String!
    var homeworkcontent : String!
    var subjectid : String!
    var subjectname : String!
    var createdby : String!
  
    var  file_path : [filePathDataDetails]!
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        homeworktopic <- map["homeworktopic"]
        homeworkcontent <- map["homeworkcontent"]
        subjectid <- map["subjectid"]
        subjectname <- map["subjectname"]
        createdby <- map["createdby"]
        file_path <- map["file_path"]
    }

}

class filePathDataDetails : Mappable{
    
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



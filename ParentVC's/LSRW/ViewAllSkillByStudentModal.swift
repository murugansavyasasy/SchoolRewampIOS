//
//  ViewAllSkillByStudentModal.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class ViewAllSkillByStudentModal           : Mappable {
    var StudentID                          : String!
    var SchoolID                           : String!
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    StudentID                           <- map["StudentID"]
    SchoolID                            <- map["SchoolID"]
   

}
}



class ViewAllSkillByStudentResponse        : Mappable {
    var Status                             : Int!
    var Message                            : String!
    var viewAllSkillByData                 : [ViewAllSkillByData]!
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    Status                                 <- map["Status"]
    Message                                <- map["Message"]
    viewAllSkillByData                     <- map["data"]
   

}
}


class ViewAllSkillByData                   : Mappable {
    var SkillId                            : Int!
    var Title                              : String!
    var Description                        : String!
    var ActivityType                       : String!
    var subject                            : String!
    var detailId                           : Int!
    var SubmittedCount                     : Int!
    var SubmittedOn                        : String!
    var Issubmitted                        : String!
    var isAppRead                          : String!
    var SentBy                             : String!
  
 
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    SkillId                                <- map["SkillId"]
    Title                                  <- map["Title"]
    Description                            <- map["Description"]
    ActivityType                           <- map["ActivityType"]
    subject                                <- map["Subject"]
    detailId                               <- map["detailId"]
    SubmittedCount                         <- map["SubmittedCount"]
    SubmittedOn                            <- map["SubmittedOn"]
    Issubmitted                            <- map["Issubmitted"]
    isAppRead                              <- map["isAppRead"]
    SentBy                                 <- map["SentBy"]
   
   

}
}




           

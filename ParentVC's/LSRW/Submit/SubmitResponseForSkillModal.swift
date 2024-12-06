//
//  SubmitResponseForSkillModal.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/22/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper

class SubmitResponseForSkillModal           : Mappable {
    var StudentID                           : String!
    var SkillId                             : String!
    var attachment                          : [AttachmentData]!
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    StudentID                               <- map["StudentID"]
    SkillId                                 <- map["SkillId"]
    attachment                              <- map["Attachment"]
   
}
}





class AttachmentData                        : Mappable {
    var content                             : String!
    var type                                : String!
  
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    content                                 <- map["content"]
    type                                    <- map["type"]
  
   

}
}


class SubmitResponse          : Mappable {
    var Message                           : String!
    var Status                             : Int!
   

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    Message                               <- map["Message"]
    Status                                 <- map["Status"]
   
   
}
}

//
//class ViewAllSkillByData                   : Mappable {
//    var SkillId                            : Int!
//    var Title                              : String!
//    var Description                        : String!
//    var ActivityType                       : String!
//    var Subject                            : String!
//    var detailId                           : Int!
//    var SubmittedCount                     : Int!
//    var SubmittedOn                        : String!
//    var Issubmitted                        : String!
//    var isAppRead                          : String!
//    var SentBy                             : String!
//  
// 
//   
//  
//    init(){}
//
//required init?(map: ObjectMapper.Map)            {
//mapping(map: map)
//}
//
//func mapping(map: ObjectMapper.Map)              {
//    
//    SkillId                                <- map["SkillId"]
//    Title                                  <- map["Title"]
//    Description                            <- map["Description"]
//    ActivityType                           <- map["ActivityType"]
//    Subject                                <- map["Subject"]
//    detailId                               <- map["detailId"]
//    SubmittedCount                         <- map["SubmittedCount"]
//    SubmittedOn                            <- map["SubmittedOn"]
//    Issubmitted                            <- map["Issubmitted"]
//    isAppRead                              <- map["SentBy"]
//    SentBy                                 <- map["Message"]
//   
//   
//
//}
//}
//
//
//
//
//           

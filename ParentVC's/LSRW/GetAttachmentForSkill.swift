//
//  GetAttachmentForSkill.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/21/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation

import ObjectMapper




class GetAttachmentForSkillModal           : Mappable {
  
    var StudentID                          : String!
    var SkillId                            : String!
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    StudentID                              <- map["StudentID"]
    SkillId                                <- map["SkillId"]
   

}
}



class GetAttachmentForSkillResponse        : Mappable {
    var Status                             : Int!
    var Message                            : String!
    var getAttachData                      : [GetAttachmentForSkillData]!
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    Status                                 <- map["Status"]
    Message                                <- map["Message"]
    getAttachData                          <- map["data"]
   

}
}



class GetAttachmentForSkillData            : Mappable {
    var SkillId                            : Int!
    var ContentId                          : Int!
    var Attachment                         : String!
    var ActivityType                       : String!
    var Order                              : Int!
 
 
   
  
    init(){}

required init?(map: ObjectMapper.Map)            {
mapping(map: map)
}

func mapping(map: ObjectMapper.Map)              {
    
    SkillId                                <- map["SkillId"]
    ContentId                              <- map["ContentId"]
    Attachment                             <- map["Attachment"]
    ActivityType                           <- map["Type"]
    Order                                  <- map["Order"]
   
   

}
}




           

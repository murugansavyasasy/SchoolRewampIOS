//
//  InsertHomeWorkModal.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 17/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import Foundation
import ObjectMapper


class InsertHomeWorkModal : Mappable {
    
    
    var CountryID : String!
    var HomeworkText : String!
    var HomeworkTopic : String!
    
    var SchoolID : String!
    var Seccode : [InsertHomeWorkSeccode]!
    var StaffID : String!
    
    var SubCode : String!
    var FilePath : [InsertHomeWorkFilePath]!
    
    
    
    init(){}
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        CountryID <- map["CountryID"]
        HomeworkText <- map["HomeworkText"]
        
        HomeworkTopic <- map["HomeworkTopic"]
        
        SchoolID <- map["SchoolID"]
        Seccode <- map["Seccode"]
        
        StaffID <- map["StaffID"]
        
        
        SubCode <- map["SubCode"]
        FilePath <- map["FilePath"]
        
        
        
        
    }
    
    
}


class InsertHomeWorkSeccode : Mappable {
    
    
    var ID : String!
    
    init(){}
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        ID <- map["ID"]
        
        
        
    }
    
    
}



class InsertHomeWorkFilePath: Mappable {
    
    
    
    
    var path : String!
    var type : String!
    
    
    
    init() {}
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        
        
        
        
        
        path <- map["path"]
        type <- map["type"]
        
        
    }
    
    
}


class InsertHomeWorkResponse: Mappable {
    
    
    var Message : String!
    var Status : Int!
    
    
    
    init() {}
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        
        
        
        
        
        Message <- map["Message"]
        Status <- map["Status"]
        
        
    }
    
    
}

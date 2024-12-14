//
//  DailycollResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 07/05/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
//import ObjectMapper
//
//class paidFeeModal : Mappable {
//    
//    
//    
//    var instituteId : String!
//    var type : Int!
//    var fromDate   : String!
//    var toDate : String!
//    
//    init(){}
//    required init?(map: ObjectMapper.Map) {
//        
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        instituteId <- map["instituteId"]
//        type <- map["Type"]
//        fromDate<-map["fromDate"]
//        toDate <- map["toDate"]
//        
//    }
//    
//    
//    
//    
//    
//}
//
//class paidFeeResp : Mappable{
//    
//    
//    
//    
//    
//    var Status : Int!
//    var Message : String!
//    var data : [PaiddataDetails]!
//    
//    required init?(map: ObjectMapper.Map) {
//        
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        Status <- map["Status"]
//        Message <- map["Message"]
//        data <- map["data"]
//    }
//    
//}
//
//
//class PaiddataDetails : Mappable{
//    
//    var Category : String!
//    var CategoryData  : [CategoryDataList]!
//    var paymentType : Int!
//    var total : String!
//    
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        Category <- map["Category"]
//        CategoryData <- map["data"]
//        total <- map["total"]
//    }
//    
//    
//    
//    
//}
//class CategoryDataList : Mappable{
//    
//    var TypeName : String!
//    var amount  : String!
//    
//    
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        TypeName <- map["TypeName"]
//        amount <- map["amount"]
//    }
//    
//    
//    
//    
//}

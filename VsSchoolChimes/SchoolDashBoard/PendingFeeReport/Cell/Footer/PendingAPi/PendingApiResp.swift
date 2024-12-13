//
//  PendingApiResp.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 07/05/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
//import ObjectMapper
//
//
//
//class DailypendingModal : Mappable{
//    
//    
//    var instituteId : String!
//    var type : Int!
//    var fromDate   : String!
//    var toDate : String!
//  
//    
//    init(){}
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        
//        mapping(map: map)
//        
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//       
//        instituteId <- map["instituteId"]
//        type <- map["Type"]
//        fromDate<-map["fromDate"]
//        toDate <- map["toDate"]
//        
//        
//    }
//    
//    
//    
//    
//    
//}
//
//
//
//
//
//class pendingModal : Mappable{
//    
//    
//    var instituteId : String!
//    var mAcadamicYearId : Int!
//    var acadamicYearId : String!
//    
//    var fromDate   : String!
//    var toDate : String!
//    
//    
//    init(){}
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        
//        mapping(map: map)
//        
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//       
//        instituteId <- map["instituteId"]
//        mAcadamicYearId <- map["mAcadamicYearId"]
//        acadamicYearId <- map["acadamicYearId"]
//        fromDate<-map["fromDate"]
//        toDate <- map["toDate"]
//        
//        
//    }
//    
//    
//    
//    
//    
//}
//
//
//
//class pendingResp : Mappable{
//  
//    
//    
//    var Status : Int!
//    var Message : String!
//    var data : [PendiRespdatadetails]!
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        Status <- map["Status"]
//        Message <- map["Message"]
//        data <- map["data"]
//        
//    }
//}
//
//
//
//class feePendingResp : Mappable{
//  
//    
//    
//    var status : Int!
//    var message : String!
//    var data : [PendiRespdatadetails]!
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        status <- map["status"]
//        message <- map["message"]
//        data <- map["data"]
//        
//    }
//}
//
//
//
//
//class PendiRespdatadetails : Mappable{
//    
//    var TypeName : String!
//    var Category : String!
//    
//    var ClassName : String!
//    var total : String!
//    var data  : [pendingDataDetails]!
// 
//    
//    required init?(map: ObjectMapper.Map) {
//        
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        Category <- map["Category"]
//        TypeName <- map["TypeName"]
//        total <- map["total"]
//        ClassName <- map["ClassName"]
//        data <- map["data"]
//    }
// 
//}
//
//
//class pendingDataDetails : Mappable{
//    
//    var feeName : String!
//    var amount  : String!
//    var TypeName : String!
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//        
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        feeName <- map["feeName"]
//        amount  <- map["amount"]
//        TypeName <- map["TypeName"]
//    }
//    
// 
//    
//}

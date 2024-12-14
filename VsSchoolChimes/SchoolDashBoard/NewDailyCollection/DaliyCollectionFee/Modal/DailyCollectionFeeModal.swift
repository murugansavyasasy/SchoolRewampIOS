//
//  DailyCollectionFeeModal.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 15/03/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import Foundation
//import ObjectMapper
//
//
//
//
//
//class DailyCollectionFeeModal : Mappable {
//    
//    
//    var schoolId : String!
//    var fromDate : String!
//    var toDate : String!
//    
//    
//    
//    init() {}
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        schoolId <- map["schoolId"]
//        fromDate <- map["fromDate"]
//        toDate <- map["toDate"]
//    }
//    
//    
//}
//
//
//
//
//class DailyCollectionFeeResponse : Mappable {
//    
//    
//    
//    var Status : String!
//    var Message : String!
//    
//    var collectioData : DailyCollectionData!
//    
//    
//    
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        Status <- map["Status"]
//        Message <- map["Message"]
//        collectioData <- map["data"]
//        
//        
//        
//    }
//    
//    
//    
//    
//}
//
//
//
//
//class DailyCollectionData : Mappable {
//    
//    
//    
//    
//    var totalCollected : TotalCollected!
//    var paymentTypeWise : [PaymentTypeWise]!
//    var previousYearFee : [PreviousYearFee]!
//    var currentYearFee : [CurrentYearFee]!
//    
//    
//    
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        totalCollected <- map["totalCollected"]
//        paymentTypeWise <- map["paymentTypeWise"]
//        previousYearFee <- map["previousYearFee"]
//        currentYearFee <- map["currentYearFee"]
//        
//        
//    }
//    
//    
//}
//
//
//
//
//class TotalCollected : Mappable {
//    
//    var name : String!
//    var paid_amount : String!
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        name <- map["name"]
//        paid_amount <- map["paid_amount"]
//        
//        
//        
//    }
//}
//
//class PaymentTypeWise : Mappable {
//    
//    var name : String!
//    var paid_amount : String!
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        name <- map["name"]
//        paid_amount <- map["paid_amount"]
//        
//        
//        
//    }
//}
//
//class PreviousYearFee : Mappable {
//    
//    var name : String!
//    var paid_amount : String!
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        name <- map["name"]
//        paid_amount <- map["paid_amount"]
//        
//        
//        
//    }
//}
//
//class CurrentYearFee : Mappable {
//    
//    var name : String!
//    var paid_amount : String!
//    
//    required init?(map: ObjectMapper.Map) {
//        mapping(map: map)
//    }
//    
//    func mapping(map: ObjectMapper.Map) {
//        
//        name <- map["name"]
//        paid_amount <- map["paid_amount"]
//        
//        
//        
//    }
//}

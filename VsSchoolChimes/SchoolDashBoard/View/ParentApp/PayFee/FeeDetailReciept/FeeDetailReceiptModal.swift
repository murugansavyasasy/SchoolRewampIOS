//
//  FeeDetailReceiptModal.swift
//  VoicesnapSchoolApp
//
//  Created by APPLE on 27/01/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


class FeeDetailReceiptModal: Mappable {

    
          
    var SchoolID : String!
    var ChildID : String!
    var FeeCategory : String!
   
    init(){}

    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        SchoolID <- map["SchoolID"]
        ChildID <- map["ChildID"]
        FeeCategory <- map["FeeCategory"]
        

        
    }
    
    
}


class FeeDetailReceiptResponse: Mappable {

    
    var status : Int!
    var message : String!
    var data : [FeeDetailReceiptData]!
   
   
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
       
            status <- map["status"]
            message <- map["message"]
            data <- map["data"]
      
        
    }
    
    
}


class FeeDetailReceiptData: Mappable {

    
     
    var id : String!
    var invoiceNo : String!
    var invoiceDate : String!
    var invoiceAmount : String!
   
   
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
       
        
      
        id <- map["id"]
        invoiceNo <- map["invoiceNo"]
        invoiceDate <- map["invoiceDate"]
        invoiceAmount <- map["invoiceAmount"]
      
        
    }
    
    
}

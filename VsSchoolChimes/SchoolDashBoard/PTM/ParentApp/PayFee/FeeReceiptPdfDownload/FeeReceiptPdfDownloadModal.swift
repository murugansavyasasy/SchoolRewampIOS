//
//  FeeReceiptPdfDownloadModal.swift
//  VoicesnapSchoolApp
//
//  Created by APPLE on 27/01/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import Foundation
import ObjectMapper



class FeeReceiptPdfDownloadModal: Mappable {
    
    
    
    var SchoolID : String!
    var InvoiceId : String!
    
    init(){}
    
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        SchoolID <- map["SchoolID"]
        InvoiceId <- map["InvoiceId"]
        
        
        
    }
    
    
}


class FeeReceiptPdfDownloadResponse: Mappable {
    
    
    var Status : String!
    var Message : String!
    var data : String!
    
    
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        Status <- map["Status"]
        Message <- map["Message"]
        data <- map["data"]
        
        
    }
    
    
}



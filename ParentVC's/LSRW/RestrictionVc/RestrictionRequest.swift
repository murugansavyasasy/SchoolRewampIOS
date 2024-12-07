//
//  RestrictionRequest.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/27/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation


class RestrictionRequest {
static func call_request(param : String, completion_handler : @escaping(String)->()) {
    
 
    
    
    
    
    
    BaseRequest.raw_post(url: get_url(), param: param).success {
        
        
        
        (res) in
        
        completion_handler (res as! String)
        
    }
    
}





private static func get_url() -> String{
    
    
    
    return String(format: "%@/GetVideoContentRestriction", StaffConstantFile.SmsBaseUrl as! CVarArg)
    
    
}



}

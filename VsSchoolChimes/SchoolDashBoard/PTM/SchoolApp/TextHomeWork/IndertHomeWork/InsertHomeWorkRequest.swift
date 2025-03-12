//
//  InsertHomeWorkRequest.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 17/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import Foundation
import KRProgressHUD


class InsertHomeWorkRequest {
    
    
    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        KRProgressHUD.show()
        print("get_url()",get_url())
        BaseRequest.raw_post(url: get_url(), param: param).success {
            
            (res) in
            completion_handler (res as! String)
        }
    }
    
    
    private static func get_url() -> String{
        
        return String(format: "%@InsertHomeWork", StaffConstantFile.SmsBaseUrl as! CVarArg )
    }
    
}

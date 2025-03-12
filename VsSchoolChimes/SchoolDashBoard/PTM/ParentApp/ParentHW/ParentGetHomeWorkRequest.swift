//
//  ParentGetHomeWorkRequest.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 25/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import Foundation

class ParentGetHomeWorkRequest {
    
    
    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        print("geParentGetHomeWorkRequestt_url",get_url())

        BaseRequest.raw_post(url: get_url(), param: param).success {
            

            (res) in
            completion_handler (res as! String)
        }
    }
    
    
    private static func get_url() -> String{
        
        print("dddd",StaffConstantFile.BaseUrl)
        return String(format: "%@GetHomeWork", StaffConstantFile.BaseUrl as! CVarArg)
        
    }
    
}

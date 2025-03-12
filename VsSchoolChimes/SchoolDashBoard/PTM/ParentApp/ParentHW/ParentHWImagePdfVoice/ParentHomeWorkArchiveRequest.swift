//
//  ParentHomeWorkArchiveRequest.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import Foundation


class ParentHomeWorkArchiveRequest {
    
    
    static func call_request(param : String, completion_handler : @escaping(String)->()) {

        print("ParentHomeWorkArchiveRequest",get_url())

        BaseRequest.raw_post(url: get_url(), param: param).success {
            
            (res) in
            completion_handler (res as! String)
        }
    }
    
    
    private static func get_url() -> String{
        
        return String(format: "%@GetHomeWork_archive", StaffConstantFile.BaseUrl as! CVarArg)
        
    }
    
}

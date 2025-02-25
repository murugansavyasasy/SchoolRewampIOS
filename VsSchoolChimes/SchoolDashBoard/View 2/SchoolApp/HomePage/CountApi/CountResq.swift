//
//  CountResq.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation



import KRProgressHUD

class CountRequest{


    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        KRProgressHUD.show()


        print("responget_urlii",get_url())
        BaseRequest.raw_post(url: get_url(), param: param).success {

            (res) in
            completion_handler (res as! String)
        }
    }




    private static func get_url() -> String {

       
        
        
        return String (format:  "%@GetOverallUnreadCountForStaff",StaffConstantFile.BaseUrl as! CVarArg )

    }


}


class VideoCountRequest{


    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        KRProgressHUD.show()


        print("responget_urlii",get_url())
        BaseRequest.raw_post(url: get_url(), param: param).success {

            (res) in
            completion_handler (res as! String)
        }
    }




    private static func get_url() -> String {

       
        
        
        return String (format:  "%@ReadStatusUpdate",StaffConstantFile.BaseUrl as! CVarArg )

    }


}


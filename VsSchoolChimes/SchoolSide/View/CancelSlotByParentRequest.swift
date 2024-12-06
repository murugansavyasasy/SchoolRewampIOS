//
//  CancelSlotByParentRequest.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 12/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import KRProgressHUD

class CancelSlotByParentRequest{

    static func call_request(param : String, completion_handler : @escaping(String)->()) {
        KRProgressHUD.show()
        
        print("get_url()",get_url())
        BaseRequest.raw_post(url: get_url(), param: param).success {

            (res) in
            completion_handler (res as! String)
        }
    }




    private static func get_url() -> String {

        return String (format:  "%@ptm-schedule/cancel-slot-by-parent",StaffConstantFile.SmsBaseUrl as! CVarArg )

    }




}

//
//  StaffListReq.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import KRProgressHUD
class staffListRequests{


    static func call_request (param : [String : Any],completion_handler : @escaping(String) -> ()) {


        KRProgressHUD.show()

        BaseRequest.getAny(url: get_url(), param: param).success {



            (res) in

            completion_handler(res as! String)

        }

    }

    private static func get_url() -> String {

        return String (format:  "%@staff-list",StaffConstantFile.SmsBaseUrl as! CVarArg )

    }



}

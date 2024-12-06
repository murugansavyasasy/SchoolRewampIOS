//
//  DateWiseSlotDetailsStaffRequest.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 16/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import KRProgressHUD


class DateWiseSlotDetailsStaffRequest{


    static func call_request (param : [String : Any],completion_handler : @escaping(String) -> ()) {


        KRProgressHUD.show()

        BaseRequest.getAny(url: get_url(), param: param).success {



            (res) in

            completion_handler(res as! String)

        }

    }

    private static func get_url() -> String {

        return String (format:  "%@ptm-schedule/datewise-slot-details-for-staff",StaffConstantFile.SmsBaseUrl as! CVarArg )

    }



}

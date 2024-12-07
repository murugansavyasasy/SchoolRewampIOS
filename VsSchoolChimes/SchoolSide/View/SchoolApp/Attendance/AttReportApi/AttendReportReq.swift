//
//  AttendReportReq.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//


import Foundation
import KRProgressHUD
class StudentAttendenceReportRequest{


    static func call_request (param : [String : Any],completion_handler : @escaping(String) -> ()) {


        KRProgressHUD.show()

        print("get_url()",get_url())
        BaseRequest.getAny(url: get_url(), param: param).success {



            (res) in

            completion_handler(res as! String)

        }

    }

    private static func get_url() -> String {

        
        return String (format:  "%@student-attendance-report",StaffConstantFile.BaseUrl as! CVarArg )
       

    }



}

//
//  GetAttachmentForSkillRequest.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/21/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import Foundation
import KRProgressHUD
class GetAttachmentForSkillRequest{


    static func call_request(param : String, completion_handler : @escaping(String)->()) {
     
        KRProgressHUD.show()
        BaseRequest.raw_post(url: get_url(), param: param).success {

            (res) in
            completion_handler (res as! String)
        }
    }




    private static func get_url() -> String {

        return String (format:  "%@GetAttachmentForSkill",StaffConstantFile.BaseUrl as! CVarArg )

    }


}

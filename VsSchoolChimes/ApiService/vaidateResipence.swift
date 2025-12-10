//
//  vaidateResipence.swift
//  VsSchoolChimes
//
//  Created by admin on 08/04/25.
//

import Foundation
import UIKit


struct common_redirection {
    
    static  let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    static  let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    
    static func recienpient_validation(isVoice : Bool ,api_request_param : [String : Any]){
        
        if(staffDetailsCount?.count ?? 0 > 1){
            if(
                staff_role == PriorityType.is_principal || staff_role == PriorityType
                    .is_grouphead || staff_role == PriorityType.is_admin){
                
                if #available(iOS 14.0, *) {
                    let vc = SchoolListVC(nibName: nil, bundle: nil)
                    vc.screen_type = screenType.is_emergencyvoice
                    vc.requestCommonDataDetails = api_request_param
                    vc.modalPresentationStyle = .fullScreen
                    let currentController = getCurrentViewController()
                    currentController?.present(vc, animated: true)
                }
            }else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.requestCommonDataDetails = api_request_param
                vc.modalPresentationStyle = .fullScreen
                let currentController = getCurrentViewController()
                currentController?.present(vc, animated: true)
            }
            
        }else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.requestCommonDataDetails = api_request_param
                vc.modalPresentationStyle = .fullScreen
                let currentController = getCurrentViewController()
                currentController?.present(vc, animated: true)
            }
       }
    
    
    static func getCurrentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
}



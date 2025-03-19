//
//  MobileNumberVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class MobileNumberVc: UIViewController {

    
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var MobilTextFld:
    UITextField!
    var AlertModal = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    
    func otp_Vc(valdiateResponse : [UserData]){
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.mobile_number = MobilTextFld.text ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func validate_user() {
        
        let secureID = SecureIDManager.getSecureID()
        var parameters: [String: Any] = [
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID
        ]
       
        
       
        APIService.shared
            .makeApi(url: ServiceUrl.validate_validate_user, parameters:parameters
                , type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                result: Result<UserValidationResponseSuc,
                Error>
            ) in
                switch result {
                case .success(let response):
                    if response.status == true {
                        DispatchQueue.main.async { [self] in
                            
//                          
//                            UserDefaultFileManager.saveLoginCredentials(mobile_number : MobilTextFld.text ?? "",pwd:passTextFld.text ?? "")
                            
                            let data : UserData = (
                                response.data?.first
                            )!
                            
                            if(data.is_number_exists == true){
                                
                                if(data.otp_sent == true){
                                   
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }
                                else {
                                    
                                    
                                }

                            }
                            else {
                                AlertModal
                                    .showAlert(
                                        title: "",
                                        message: response.message ?? "",
                                        on: self
                                    )
                            }
                            
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            AlertModal
                                .showAlert(
                                    title: "",
                                    message: response.message ?? "",
                                    on: self
                                )
                            
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
        
    }

}

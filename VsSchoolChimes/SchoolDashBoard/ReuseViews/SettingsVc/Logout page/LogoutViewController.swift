
//  LogoutViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 06/11/24.
//

import UIKit

class LogoutViewController: UIViewController {

    @IBOutlet weak var DescribeLabel: UILabel!
    @IBOutlet var overallview: UIView!
    @IBOutlet weak var LogoutView: UIView!
    @IBOutlet weak var Cancellabel: UILabel!
    @IBOutlet weak var LogoutButtonView: UIButton!
    
    let secureID = SecureIDManager.getSecureID()
    let IsParent = UserDefaultFileManager.getUserDetails()?.user_details?.is_parent
    let childDetails = UserDefaultFileManager.get_child_Details()
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    let mobileNo = UserDefaultFileManager.getLoginCredentials()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DescribeLabel.text = AlertstringFile.ConfirmLogout.translated()
        Cancellabel.text = AlertstringFile.Cancel.translated()
        
        DescribeLabel.setFont(style: .title, size: FontSize.TitleSize)
        Cancellabel.setFont(style: .body, size: FontSize.BodySize)
        LogoutButtonView.setTitleFont(style: .body, size: FontSize.BodySize)
        LogoutButtonView.setTitle(CommonStringFile.Logout.translated(), for: .normal)
        LogoutButtonView.titleLabel?.adjustsFontSizeToFitWidth = true
        overallview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        LogoutView.layer.cornerRadius = Colornames.CORadius10
        LogoutView.layer.shadowColor = UIColor.black.cgColor
        LogoutView.layer.shadowOpacity = 0.5
        LogoutView.layer.shadowOffset = CGSize(width: 4, height: 4)
        LogoutView.layer.shadowRadius = 3
        LogoutView.layer.masksToBounds = false
        LogoutButtonView.layer.cornerRadius = Colornames.CORadius15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CancelAct))
        Cancellabel.addGestureRecognizer(tap)
        Cancellabel.isUserInteractionEnabled = true
    }
    
    @IBAction func LogoutAct(_ sender: Any) {
//        UserDefaultFileManager.removeLoginCredentials()
//        if #available(iOS 14.0, *) {
//            let vc = LoginVc(nibName: nil, bundle: nil)
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true)
//        }
//        UserDefaultFileManager.removeLoginCredentials()
//            
//        if #available(iOS 15.0, *) {
//            let loginVC = LoginVc(nibName: nil, bundle: nil)
//            let nav = UINavigationController(rootViewController: loginVC)
//            nav.navigationBar.isHidden = true
//            
//            if let window = UIApplication.shared.connectedScenes
//                .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
//                window.rootViewController = nav
//                window.makeKeyAndVisible()
//            }
//        }
           
        Logout_Api()
    }
    
    @objc func CancelAct(_ sender: Any){
        self.dismiss(animated: false, completion: nil)
    }
    
    func Logout_Api(){
        
        if #available(iOS 15.0, *) {showActivityLoader() }
        
        
        print("secureIDsecureIDsecureID",secureID)
        let param : [String:Any] = [
            COMMON_PARAMETER.mobile_number : mobileNo?.mobile_number ?? "",
            COMMON_PARAMETER.device_type: API_PARAMS_HOTCODE.device_type,
            "secure_id": secureID
        ]
        
        let token = (IsParent == true ? childDetails?.access_token : staffDetails?.access_token) ?? ""
        
        APIService.shared.makeApi(url: ServiceUrl.app_api_auth_logout, parameters: param, type: ApitTypeSringFile.POST, token: token) { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self.hideActivityLoader() }
                switch result {
                case .success(let success):
                   
                    UserDefaultFileManager.removeLoginCredentials()
                        
                    if #available(iOS 15.0, *) {
                        let loginVC = LoginVc(nibName: nil, bundle: nil)
                        let nav = UINavigationController(rootViewController: loginVC)
                        nav.navigationBar.isHidden = true
                        
                        if let window = UIApplication.shared.connectedScenes
                            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
                            window.rootViewController = nav
                            window.makeKeyAndVisible()
                        }
                    }
                    
                case .failure(let failure):
                    print("Error: ", failure.localizedDescription)
                }
            }
        }
    }
    
}

//
//  MobileNumberViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 17/06/24.
//

import UIKit



class MobileNumberViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//
//    func callUserDetailsValidation () {
//        let strUDID = UIDevice.current.identifierForVendor!.uuidString
//
//        let parameters: [String: Any] = [
//            "MobileNumber": "",
//            "Password":"",
//            "DeviceType": "Iphone",
//            "SecureID": strUDID
//        ]
//        
//        
//
//        print(parameters)
//        
//        let url = MethodNames.baseURL + MethodNames.countryList
//        
//        AF.request(url, method: .post, parameters: parameters).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                print("JSON: \(value)")
//                //                    print("response.result",response.result)
//                //                    print("response.statusCode",response.response)
//                do {
//                    
//                    let model = try JSONDecoder().decode(CountryListResponse.self, from: response.data!)
//                    print("Model: \(model)")
//                 
//                    
//                } catch {
//                    print("Decoding error: \(error)")
//                }
//            case .failure(let error):
//                print("Error: \(error)")
//                
//                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
//                    print("Response data: \(responseString)")
//                }
//            }
//            
//        }
//    }
}

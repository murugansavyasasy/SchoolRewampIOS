//
//  ViewModal.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import Foundation



class Login {
    
    func postMethod(CountryID: Int, DeviceType: String, MobileNumber: String, Password: String, SecureID: String, completion: @escaping (Result<[LoginResponseData], Error>) -> Void) {
        
        // Use the provided URL
        guard let url = URL(string:MethodName.baseURL + MethodName.LoginURL) else {
            print("Invalid URL")
            return
        }
        
        // Define the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer yourTokenHere", forHTTPHeaderField: "Authorization")  // Add your token if needed
        
        // Create the body data (convert Swift object to JSON)
        let parameters: [String: Any] = [
            RequestName.CountryID : CountryID,
            RequestName.DeviceType : DeviceType,
            RequestName.MobileNumber : MobileNumber,
            RequestName.Password : Password,
            RequestName.SecureID  : SecureID
        ]
        
        print("parameters: \(parameters)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON:", error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200, let data = data {
                    do {
                       
                        
                        // noncodeDecobelResponce for Print Prurpose
                        
                        let rawResponse = String(data: data, encoding: .utf8) ?? "No readable data"
                                            print("Raw response datadafed:", rawResponse)
                        
                        //
                        
                        
                        
                        // Decode as an array of LoginResponseData
                        let decodedResponse = try JSONDecoder().decode([LoginResponseData].self, from: data)
//                        print("Decoded response:", decodedResponse)
                        
                      
                        
                        // Return the response using the completion handler
                        completion(.success(decodedResponse))
                    } catch {
                        print("Error decoding response:", error)
                        completion(.failure(error))
                    }
                } else {
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server responded with status code \(httpResponse.statusCode)"])
                    completion(.failure(statusError))
                }
            }
        }
        
        task.resume()
        
    }
   
    
}

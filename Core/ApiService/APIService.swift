import Foundation
import UIKit

class APIService: NSObject, URLSessionDelegate {
    
    static let shared = APIService()
    var session = URLSession(configuration: .default)
    
    override private init() {
        super.init()
    }
    
    // MARK: - Main API Call
    func makeApi<T: Codable>(
        url: String,
        parameters: [String: Any]? = nil,
        type: String,
        token: String,
        isBaseUrl: Bool,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        guard NetworkMonitor.shared.isConnected else {
            let error = getError(statusCode: 0, description: "No internet connection. Please check your network.")
            completionHandler(.failure(error))
            return
        }
        
        guard let fullURL = buildURLWithQueryParams(path: url, queryParams: parameters, method: type, baseUrlType: token, isBaseUrl: isBaseUrl ) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }
        print("✅ Request URL: \(fullURL)")
        print("📦 Parameters: \(parameters ?? [:])")
        print("TOKEN : \(token)")
        print("isBaseUrl \(isBaseUrl)")

        var request = URLRequest(url: fullURL)
        if token != PaucketHeader.Paucket{
            request.httpMethod = type
            request.addValue("Application/json", forHTTPHeaderField: "Accept")
            request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }else{
            request.httpMethod = type
            request.addValue("Application/json", forHTTPHeaderField: "Accept")
            request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(PaucketHeader.api_key_value, forHTTPHeaderField: PaucketHeader.api_key)
            request.addValue(PaucketHeader.partner_name_value, forHTTPHeaderField: PaucketHeader.partner_name)
        }
        
        if (type == "POST" || type == "PUT"), let parameters = parameters {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            } catch let jsonError {
                print("❌ JSON Encoding Error: \(jsonError.localizedDescription)")
            }
        }
        session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    if let raw = String(data: data, encoding: .utf8) {
                        print("🔥 RAW SERVER RESPONSE:\n\(raw)")
                    }
                    completionHandler(.success(result))
                } catch let decodeError {
                    if let resultJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                       let message = resultJson["message"] as? String {
                        let error = self.getError(statusCode: httpResponse.statusCode, description: message)
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.failure(decodeError))
                    }
                }
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                let error = self.getError(statusCode: 0, description: "API Call failed with unknown error")
                completionHandler(.failure(error))
            }
        }.resume()
    }
    
    
    // MARK: - Build URL with query parameters for GET
    private func buildURLWithQueryParams(path: String, queryParams: [String: Any]?, method: String,baseUrlType:String,isBaseUrl:Bool) -> URL? {
        
        let baseURL: String
        if baseUrlType != PaucketHeader.Paucket {
            if isBaseUrl{
                baseURL = ServiceUrl.baseurl
            }else{
                baseURL = ServiceUrl.Reporting_baseurl
            }
        } else {
                baseURL = ServiceUrl.Pacukt_baseurl
        }
        var components = URLComponents(string: baseURL + path)
        if method.uppercased() == "GET", let queryParams = queryParams {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        return components?.url
    }
    
    // MARK: - Error Helper
    func getError(statusCode: Int, description: String) -> Error {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "\(statusCode)", code: statusCode, userInfo: userInfo)
    }
    
    // MARK: - PUT
//    func putApi<T: Codable>(
//        url: String,
//        parameters: [String: Any],
//        token: String,
//        completionHandler: @escaping (Result<T, Error>) -> Void
//    ) {
//        makeApi(url: url, parameters: parameters, type: "PUT", token: token, completionHandler: completionHandler)
//    }
//    
//    // MARK: - DELETE
//    func deleteApi<T: Codable>(
//        url: String,
//        token: String,
//        completionHandler: @escaping (Result<T, Error>) -> Void
//    ) {
//        makeApi(url: url, parameters: nil, type: "DELETE", token: token, completionHandler: completionHandler)
//    }
    
    // MARK: - PTM Api
    func PtmApi<T: Codable>(
        url: String,
        parameters: [[String: Any]],
        token: String,
        isBaseUrl : Bool,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        print("Param",parameters)
        var baseUrl:String = ""
        if isBaseUrl{
            baseUrl = ServiceUrl.baseurl
        }else{
            baseUrl = ServiceUrl.Reporting_baseurl
        }
        guard let fullURL = URL(string: baseUrl + url) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        print("✅ Request URL: \(fullURL)")
        print("📦 Parameters: \(parameters)")
        print("TOKEN : \(token)")
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completionHandler(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completionHandler(.success(result))
                    print("response: ", result)
                } catch {
                    completionHandler(.failure(error))
                }
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                let error = self.getError(statusCode: 0, description: "Unknown error")
                completionHandler(.failure(error))
            }
        }.resume()
    }
    
    //MARK: AI Image Post method API
    func uploadImageApi<T: Codable>(
        url: String,
        image: UIImage,
        type: String = "POST",
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {

        guard NetworkMonitor.shared.isConnected else {
            let error = getError(statusCode: 0, description: "No internet connection.")
            completionHandler(.failure(error))
            return
        }

        guard let fullURL = URL(string: ServiceUrl.baseurl + url) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }

        print("✅ Upload URL:", fullURL.absoluteString)

        var request = URLRequest(url: fullURL)
        request.httpMethod = type
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            let error = getError(statusCode: 0, description: "Image conversion failed")
            completionHandler(.failure(error))
            return
        }

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                let error = self.getError(statusCode: 0, description: "No response from server")
                completionHandler(.failure(error))
                return
            }
            print("📡 Status Code:", httpResponse.statusCode)
                 print("📦 Raw Response:\n", data.toPrettyString())
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(result))
            } catch {
                print("❌ Decoding Error:", error)
                print("📦 Failed JSON:\n", data.toPrettyString())
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    let error = self.getError(statusCode: httpResponse.statusCode, description: message)
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(error))
                }
            }
        }.resume()
    }


}

extension Data {
    mutating func append(_ string: String) {
        append(string.data(using: .utf8)!)
    }
    
}
extension Data {
    func toPrettyString() -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: self),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return String(data: self, encoding: .utf8) ?? "❌ Unable to convert data to string"
    }
}

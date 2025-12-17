import Foundation


import Foundation

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
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        guard NetworkMonitor.shared.isConnected else {
            let error = getError(statusCode: 0, description: "No internet connection. Please check your network.")
            completionHandler(.failure(error))
            return
        }
        
        guard let fullURL = buildURLWithQueryParams(path: url, queryParams: parameters, method: type, baseUrlType: token ) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        print("✅ Request URL: \(fullURL)")
        print("📦 Parameters: \(parameters ?? [:])")
        print("TOKEN : \(token)")

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
    private func buildURLWithQueryParams(path: String, queryParams: [String: Any]?, method: String,baseUrlType:String) -> URL? {
        
        let baseURL: String
        if baseUrlType != PaucketHeader.Paucket {
            baseURL = ServiceUrl.baseurl
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
    func putApi<T: Codable>(
        url: String,
        parameters: [String: Any],
        token: String,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        makeApi(url: url, parameters: parameters, type: "PUT", token: token, completionHandler: completionHandler)
    }
    
    // MARK: - DELETE
    func deleteApi<T: Codable>(
        url: String,
        token: String,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        makeApi(url: url, parameters: nil, type: "DELETE", token: token, completionHandler: completionHandler)
    }
    
    // MARK: - PTM Api
    func PtmApi<T: Codable>(
        url: String,
        parameters: [[String: Any]],
        token: String,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        print("Param",parameters)
        guard let fullURL = URL(string: ServiceUrl.baseurl + url) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if token != PaucketHeader.Paucket {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        } else {
            request.addValue(PaucketHeader.api_key_value, forHTTPHeaderField: PaucketHeader.api_key)
            request.addValue(PaucketHeader.partner_name_value, forHTTPHeaderField: PaucketHeader.partner_name)
        }
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
}

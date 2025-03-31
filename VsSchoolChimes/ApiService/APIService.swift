import Foundation

class APIService: NSObject, URLSessionDelegate {
    static let shared = APIService()
    var session = URLSession(configuration: .default)
    
    override private init() {
        super.init()
    }
    
    func makeApi<T: Codable>(url: String, parameters: [String: Any]?, type: String, token: String, completionHandler: @escaping (Swift.Result<T, Error>) -> Void) {
        if let url = URL(string: ServiceUrl.baseurl + url) {
            
            print("Request URL: \(url)")
            print("Parameters: \(parameters ?? [:])")
            print("URLSS", url)
            
            session.dataTask(with: getUrl(url: url, parameter: parameters, type: type, token: token)) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let data = data {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
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
                    let errorMessage = "API Call failed with unknown error"
                    print(errorMessage)
                    let error = self.getError(statusCode: 0, description: errorMessage)
                    completionHandler(.failure(error))
                }
            }.resume()
        }
    }
    
    func getUrl(url: URL, parameter: [String: Any]?, type: String, token: String) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = type
        urlRequest.addValue("Application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        
        if type == "POST" || type == "PUT" {
            if let parameter = parameter {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameter)
                    urlRequest.httpBody = jsonData
                } catch let jsonError {
                    print("JSON Encoding Error: \(jsonError.localizedDescription)")
                }
            }
        }
        return urlRequest
    }
    
    func getError(statusCode: Int, description: String) -> Error {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: NSLocalizedString("", value: description, comment: "")]
        return NSError(domain: "\(statusCode)", code: statusCode, userInfo: userInfo)
    }
    
    // MARK: - PUT Request
    func putApi<T: Codable>(url: String, parameters: [String: Any], token: String, completionHandler: @escaping (Swift.Result<T, Error>) -> Void) {
        makeApi(url: url, parameters: parameters, type: "PUT", token: token, completionHandler: completionHandler)
    }
    
    // MARK: - DELETE Request
    func deleteApi<T: Codable>(url: String, token: String, completionHandler: @escaping (Swift.Result<T, Error>) -> Void) {
        makeApi(url: url, parameters: nil, type: "DELETE", token: token, completionHandler: completionHandler)
    }
}

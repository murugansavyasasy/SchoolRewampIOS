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
        
        guard let fullURL = buildURLWithQueryParams(path: url, queryParams: parameters, method: type) else {
            let error = getError(statusCode: 0, description: "Invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        print("✅ Request URL: \(fullURL)")
        print("📦 Parameters: \(parameters ?? [:])")
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = type
        request.addValue("Application/json", forHTTPHeaderField: "Accept")
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
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
    private func buildURLWithQueryParams(path: String, queryParams: [String: Any]?, method: String) -> URL? {
        var components = URLComponents(string: ServiceUrl.baseurl + path)

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
}

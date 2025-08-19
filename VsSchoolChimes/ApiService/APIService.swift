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
            baseURL = ServiceUrl.baseurl // or a different one like ServiceUrl.paucketBaseURL
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
}
//import Foundation
//
//class APIService: NSObject {
//    static let shared = APIService()
//    
//    private var session: URLSession
//    private var activeTasks = Set<URLSessionTask>()
//    private let taskQueue = DispatchQueue(label: "com.apiService.taskQueue", attributes: .concurrent)
//
//    override private init() {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 30
//        config.timeoutIntervalForResource = 60
//        self.session = URLSession(configuration: config)
//        super.init()
//    }
//
//    // MARK: - Generic API Call
//    @discardableResult
//    func makeApi<T: Codable>(
//        url: String,
//        parameters: [String: Any]? = nil,
//        type: String,
//        token: String,
//        maxRetries: Int = 0,
//        completionHandler: @escaping (Result<T, Error>) -> Void
//    ) -> URLSessionTask? {
//        guard NetworkMonitor.shared.isConnected else {
//            completionHandler(.failure(getError(statusCode: 0, description: "No internet connection.")))
//            return nil
//        }
//
//        guard let fullURL = buildURLWithQueryParams(path: url, queryParams: parameters, method: type) else {
//            completionHandler(.failure(getError(statusCode: 0, description: "Invalid URL.")))
//            return nil
//        }
//
//        var request = URLRequest(url: fullURL)
//        request.httpMethod = type.uppercased()
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(token, forHTTPHeaderField: "Authorization")
//
//        if ["POST", "PUT"].contains(type.uppercased()), let parameters = parameters {
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//            } catch {
//                completionHandler(.failure(error))
//                return nil
//            }
//        }
//
//        var currentRetry = 0
//
//        func performRequest() -> URLSessionTask {
//            let safeRequest = request  // ✅ Now safe to capture
//            var task: URLSessionTask!
//
//            let completion: (Data?, URLResponse?, Error?) -> Void = { [weak self] data, response, error in
//                guard let self else { return }
//
//                if let nsError = error as NSError?, nsError.code == NSURLErrorTimedOut, currentRetry < maxRetries {
//                    currentRetry += 1
//                    print("🔁 Retry \(currentRetry)/\(maxRetries): \(safeRequest.url?.absoluteString ?? "")")
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//                        let retryTask = performRequest()
//                        self.addTask(retryTask)
//                        retryTask.resume()
//                    }
//                    return
//                }
//
//                self.removeTask(task)
//
//                guard let data, let httpResponse = response as? HTTPURLResponse else {
//                    completionHandler(.failure(error ?? self.getError(statusCode: 0, description: "Unknown error.")))
//                    return
//                }
//
//                do {
//                    let decoded = try JSONDecoder().decode(T.self, from: data)
//                    completionHandler(.success(decoded))
//                } catch {
//                    if let resultJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let message = resultJson["message"] as? String,
//                       let code = resultJson["code"] as? Int {
//                        completionHandler(.failure(self.getError(statusCode: code, description: message)))
//                    } else {
//                        completionHandler(.failure(error))
//                    }
//                }
//            }
//
//            task = session.dataTask(with: safeRequest, completionHandler: completion)
//            self.addTask(task)
//            return task
//        }
//
//
//
//        let task = performRequest()
//        task.resume()
//        return task
//    }
//
//    // MARK: - Helpers
//
//    private func buildURLWithQueryParams(path: String, queryParams: [String: Any]?, method: String) -> URL? {
//        var components = URLComponents(string: ServiceUrl.baseurl + path)
//        if method.uppercased() == "GET", let queryParams {
//            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
//        }
//        return components?.url
//    }
//
//    private func getError(statusCode: Int, description: String) -> Error {
//        NSError(domain: "APIService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: description])
//    }
//
//    private func addTask(_ task: URLSessionTask) {
//        taskQueue.async(flags: .barrier) {
//            self.activeTasks.insert(task)
//        }
//    }
//
//    private func removeTask(_ task: URLSessionTask) {
//        taskQueue.async(flags: .barrier) {
//            self.activeTasks.remove(task)
//        }
//    }
//
//    // MARK: - PUT
//    @discardableResult
//    func putApi<T: Codable>(
//        url: String,
//        parameters: [String: Any],
//        token: String,
//        maxRetries: Int = 0,
//        completionHandler: @escaping (Result<T, Error>) -> Void
//    ) -> URLSessionTask? {
//        makeApi(url: url, parameters: parameters, type: "PUT", token: token, maxRetries: maxRetries, completionHandler: completionHandler)
//    }
//
//    // MARK: - DELETE
//    @discardableResult
//    func deleteApi<T: Codable>(
//        url: String,
//        token: String,
//        maxRetries: Int = 0,
//        completionHandler: @escaping (Result<T, Error>) -> Void
//    ) -> URLSessionTask? {
//        makeApi(url: url, parameters: nil, type: "DELETE", token: token, maxRetries: maxRetries, completionHandler: completionHandler)
//    }
//
//    // MARK: - Cancel All
//    func cancelAllTasks() {
//        taskQueue.async(flags: .barrier) {
//            self.activeTasks.forEach { $0.cancel() }
//            self.activeTasks.removeAll()
//        }
//    }
//
//    // MARK: - Deinit
//    deinit {
//        cancelAllTasks()
//        session.invalidateAndCancel()
//        print("\(Self.self) deallocated")
//    }
//}

//
//  API.swift
//
//
//  Created by Alexander Kozharsky on 05.02.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

import Alamofire
import ObjectMapper

typealias APIRequest = Request
typealias APICompletion = ([Mappable], String?) -> Void
typealias APIThenCompletion = () -> Void

protocol APIResource {
    func `return`(with this: APIThenCompletion) -> APIRequest
}

struct API {
    static let apiUrl = "http://192.168.2.179/api/robots"
    static var currentRequest: APIRequest?

    static var state: URLSessionTask.State {
        if let currentRequest = self.currentRequest, let task = currentRequest.task {
            return task.state
        } else {
            return .completed
        }
    }
    
    static var debug: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "APIDebug")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "APIDebug")
        }
    }
    
    static var running: Bool {
        return self.state != .completed
    }
    

    /**
     Network request
     - Parameter apiCommand: API command to execute
     - Parameter model: Model type for JSON response
     - Parameter method: HTTP response method
     - Parameter parameters: JSON dictionary for send
     - Parameter completion: Completion closure contains 3 parameters:
     - Parameter completion #1: Array of requested models
     - Parameter completion #2: Error string
     */
    @discardableResult
    static func Request<T: Mappable>(apiCommand: String, model: T.Type, method: HTTPMethod = .get, parameters: Parameters = [:], retries: Int = 3 , completion: @escaping APICompletion) -> APIRequest {
        let url = "\(self.apiUrl)\(apiCommand)"
        
        self.currentRequest = Alamofire.request(url, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default)
            .responseJSON { response in
                if self.debug {
                    print("✅✅✅")
                    print(response)
                    print("💹💹💹")
                }
                
                switch response.result {
                case .failure(let error):
                    if self.debug {
                        print("❌❌❌")
                        print(response)
                        print("⛔️⛔️⛔️")
                    }
                    
                    if retries > 0 {
                        let retriesCount = retries - 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            print("Network retrying after [\(error.localizedDescription)] error (\(retriesCount) left)")
                            self.Request(apiCommand: apiCommand, model: model, method: method, parameters: parameters, retries: retriesCount, completion: completion)
                        }
                        return
                    } else {
                        completion([], "Network error: \(error.localizedDescription)")
                    }
                case .success(let value):
                    var jsonArray: [[String: Any]] = []
                    var retArray: [T] = []
                    
                    if let json = value as? [[String: Any]] {
                        jsonArray = json
                    } else if let json = value as? [String: Any] {
                        if let networkError = json["error"] as? String {
                            completion([], "\(networkError)")
                            return
                        } else {
                            jsonArray = [json]
                        }
                    } else {
                        completion([], "Serialization error")
                    }
                    
                    for dict in jsonArray {
                        if let mod = model.init(JSON: dict) as T! {
                            retArray.append(mod)
                        }
                    }
                    
                    completion(retArray, nil)
                }
        }
        
        if self.debug {
            self.printInfo(for: self.currentRequest, and: parameters)
        }
        
        return self.currentRequest!
    }
    
    private static func printInfo(for request: Request?, and parameters: Parameters) {
        guard let request = request else {
            print("🚫🚫🚫 Network request is NIL")
            return
        }

        print("✳️✳️✳️ \(request)")
        
        for requestLine in request.debugDescription.components(separatedBy: "\\") {
            if let requestLineByKey = requestLine.components(separatedBy: "-H ").last?.components(separatedBy: "\n").first {
                let printLine = requestLineByKey == "$ curl -i " ? "HEADERS:" : "- \(requestLineByKey)"
                print(printLine == "- " ? "PARAMS:" : printLine)
            }
        }
        
        if parameters.count == 0 {
            print("- NONE")
        } else {
            for (key, value) in parameters {
                print("\(key): \(value)")
            }
        }
        
        print("❇️❇️❇️")
    }
}

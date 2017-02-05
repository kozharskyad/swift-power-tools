//
//  Network.swift
//
//
//  Created by Alexander Kozharsky on 21.01.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

import Alamofire
import ObjectMapper

typealias NetworkCompletion = ([Mappable], String?) -> Void

/** Network controller */
class Network {
    //MARK: Public properties
    static let shared = Network()
    static var currentRequest: Request?
    static var debug = false
    
    static var state: URLSessionTask.State {
        if let currentRequest = self.currentRequest, let task = currentRequest.task {
            return task.state
        } else {
            return .completed
        }
    }
    
    static var running: Bool {
        return self.state != .completed
    }
    
    static var apiUrl: String {
        return "http://192.168.2.179/api/robots"
    }
    
    //MARK: Public class methods
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
    class func request<T: Mappable>(apiCommand: String, model: T.Type, method: HTTPMethod = .get, parameters: Parameters = [:], retries: Int = 3 , completion: @escaping NetworkCompletion) -> Request {
        let url = "\(self.apiUrl)\(apiCommand)"
        
        if self.debug {
            debugPrint("NETREQUEST: \(method.rawValue) \(url)")
            debugPrint(parameters)
            debugPrint("=====================================")
        }
        
        self.currentRequest = Alamofire.request(url, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default)
            .responseJSON { response in
                
                if self.debug {
                    debugPrint("NETRESPONSE: \(response.request?.httpMethod ?? "??") \(response.request?.url?.absoluteString ?? "??")")
                    debugPrint("\(response.result.description)")
                    debugPrint("=====================================")
                }
                
                switch response.result {
                case .failure(let error):
                    if retries > 0 {
                        let retriesCount = retries - 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            print("Network retrying after [\(error.localizedDescription)] error (\(retriesCount) left)")
                            self.request(apiCommand: apiCommand, model: model, method: method, parameters: parameters, retries: retriesCount, completion: completion)
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
        return self.currentRequest!
    }
}

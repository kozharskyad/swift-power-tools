//
//  Test.swift
//
//
//  Created by Alexander Kozharsky on 05.02.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

extension API {
    enum Test: APIResource {
        case TestRoute(parameters: [String: Any], completion: APICompletion)
        
        @discardableResult
        internal func execute(after closure: APIThenCompletion = {}) -> APIRequest {
            let request: APIRequest
            
            switch self {
            case .TestRoute(let parameters, let completion):
                request = API.Request(apiCommand: "test", model: NetworkHeader.self, method: .post, parameters: parameters, retries: 3, completion: completion)
            }
            
            closure()

            return request
        }
    }
}

//
//  Robots.swift
//
//
//  Created by Alexander Kozharsky on 05.02.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

extension API {
    enum Robots: APIResource {
        case All(completion: APICompletion)
        
        @discardableResult
        internal func `return`(with this: APIThenCompletion = {}) -> APIRequest {
            let request: APIRequest
            
            switch self {
            case .All(let completion):
                request = API.Request(apiCommand: "", model: Robot.self, completion: completion)
            }
            
            this()
            
            return request
        }
    }
}

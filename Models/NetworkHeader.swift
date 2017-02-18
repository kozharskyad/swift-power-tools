//
//  NetworkHeader.swift
//  gtmtest
//
//  Created by Alexander Kozharsky on 18.02.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

import ObjectMapper

struct NetworkHeader: Mappable {
    var accept: String?
    var acceptEncoding: String?
    var connection: String?
    var contentType: String?
    var host: String?
    var contentLength: String?
    var userAgent: String?
    var acceptLanguage: String?
    
    init?(map: Map) {
        //MARK: Dummy mapper init
    }
    
    mutating func mapping(map: Map) {
        self.accept <- map["Accept"]
        self.acceptEncoding <- map["Accept-Encoding"]
        self.connection <- map["Connection"]
        self.contentType <- map["Content-Type"]
        self.host <- map["Host"]
        self.contentLength <- map["Content-Length"]
        self.userAgent <- map["User-Agent"]
        self.acceptLanguage <- map["Accept-Language"]
    }
}

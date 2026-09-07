//
//  URLRequestExtensions.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import Foundation


extension URLRequest {
    
    mutating func setBasicAuth(username: String, password: String) {
        let authString = "\(username):\(password)"
        guard let authData = authString.data(using: .utf8) else { return }
        let base64Auth = authData.base64EncodedString()
        
        self.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
    }
    
}

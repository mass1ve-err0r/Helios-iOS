//
//  RegisterReceiverRequest.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import Foundation


struct RegisterReceiverRequest: Encodable {
    let name: String
    let token: String // APNs device token (hex)
    let registrationToken: String // value entered or scanned during onboarding

    
    enum CodingKeys: String, CodingKey {
        case name
        case token
        case registrationToken = "registration_token"
    }
    
}

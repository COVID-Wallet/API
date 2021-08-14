//
//  HasCertificateData.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

protocol HasCertificateData {
    
    var diseaseAgentTargeted: String { get }
    var country: String { get }
    var certificateIssuer: String { get }
    var certificateIdentifier: String { get }
}

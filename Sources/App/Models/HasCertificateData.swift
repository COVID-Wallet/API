//
//  HasCertificateData.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

protocol HasCertificateData {
    
    var diseaseAgentTargeted: DiseaseAgentTargeted { get }
    var country: String { get }
    var certificateIssuer: String { get }
    var certificateIdentifier: String { get }
}

extension COVIDPass.Data.CertificateData {
    
    var diseaseAgentTargeted: DiseaseAgentTargeted {
        switch self {
        case .recovery(let cd as HasCertificateData),
             .test(let cd as HasCertificateData),
             .vaccination(let cd as HasCertificateData):
            return cd.diseaseAgentTargeted
        }
    }
    
    var country: String {
        switch self {
        case .recovery(let cd as HasCertificateData),
             .test(let cd as HasCertificateData),
             .vaccination(let cd as HasCertificateData):
            return cd.country
        }
    }
    
    var certificateIssuer: String {
        switch self {
        case .recovery(let cd as HasCertificateData),
             .test(let cd as HasCertificateData),
             .vaccination(let cd as HasCertificateData):
            return cd.certificateIssuer
        }
    }
    
    var certificateIdentifier: String {
        switch self {
        case .recovery(let cd as HasCertificateData),
             .test(let cd as HasCertificateData),
             .vaccination(let cd as HasCertificateData):
            return cd.certificateIdentifier
        }
    }
}

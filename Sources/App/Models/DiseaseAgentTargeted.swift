//
//  DiseaseAgentTargeted.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

enum DiseaseAgentTargeted {
    
    case covid19
    
    init?(code: String) {
        switch code {
        case "840539006":
            self = .covid19
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .covid19:
            return "COVID-19"
        }
    }
}

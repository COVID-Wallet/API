//
//  VaccineProduct.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

enum VaccineProduct {
    
    case comirnaty
    case janssen
    case moderna
    case vaxzevria
    
    init?(code: String) {
        switch code {
        case "EU/1/20/1507":
            self = .moderna
        case "EU/1/20/1525":
            self = .janssen
        case "EU/1/20/1528":
            self = .comirnaty
        case "EU/1/21/1529":
            self = .vaxzevria
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .comirnaty:
            return "Comirnaty"
        case .janssen:
            return "Covid-19 Vaccine Janssen"
        case .moderna:
            return "Covid-19 Vaccine Moderna"
        case .vaxzevria:
            return "Vaxzevria"
        }
    }
}

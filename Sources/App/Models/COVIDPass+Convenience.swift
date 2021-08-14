//
//  COVIDPass+Convenience.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

extension COVIDPass {
    
    var shortName: String {
        data.name.humanReadable.forenames.capitalized
    }
    
    var fullName: String {
        [data.name.humanReadable.forenames, data.name.humanReadable.surnames].reduce("") {
            guard $0 != "" else {
                return $1
            }
            
            return "\($0) \($1)"
        }.capitalized
    }
    
    var expiryDate: Date {
        Date(timeIntervalSince1970: TimeInterval(validUntil))
    }
    
    var expiryDatePassFormat: String {
        DateFormatterCache.shared.passFormatter.string(from: expiryDate)
    }
    
    var expiryDateHumanFormat: String {
        DateFormatterCache.shared.humanReadableFormatter.string(from: expiryDate)
    }
    
    var prophylaxisName: String? {
        switch data.vaccination.vaccineProphylaxis {
        case "1119305005":
            return "Vacina COVID-19 (antigénio)"
        case "1119349007":
            return "Vacina COVID-19 (mRNA)"
        default:
            return "Vacina COVID-19"
        }
    }
    
    var productName: String? {
        switch data.vaccination.vaccineProduct {
        case "EU/1/20/1507":
            return "Covid-19 Vaccine Moderna"
        case "EU/1/20/1525":
            return "Covid-19 Vaccine Janssen"
        case "EU/1/20/1528":
            return "Comirnaty"
        case "EU/1/21/1529":
            return "Vaxzevria"
        default:
            return nil
        }
    }
}

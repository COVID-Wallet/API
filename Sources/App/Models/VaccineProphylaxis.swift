//
//  VaccineProphylaxis.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

enum VaccineProphylaxis {
    
    case antigen
    case mRNA
    
    init?(code: String) {
        switch code {
        case "1119305005":
            self = .antigen
        case "1119349007":
            self = .mRNA
        default:
            return nil
        }
    }
    
    func name(language: SupportedLanguage) -> String {
        switch self {
        case .antigen:
            switch language {
            case .english:
                return "COVID-19 Vaccine (antigen)"
            case .portuguese:
                return "Vacina COVID-19 (antigénio)"
            }
            
        case .mRNA:
            switch language {
            case .english:
                return "COVID-19 Vaccine (mRNA)"
            case .portuguese:
                return "Vacina COVID-19 (mRNA)"
            }
        }
    }
}

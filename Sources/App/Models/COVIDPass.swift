//
//  COVIDPass.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 10/08/2021.
//

import Foundation

protocol NameRepresentable {
    
    var forenames: String { get }
    var surnames: String { get }
}

struct COVIDPass {
    
    struct Data {
        
        struct Name {
            
            struct HumanReadable: NameRepresentable {
                
                let forenames: String   //  gn
                let surnames: String    //  fn
            }
            
            struct Standardised: NameRepresentable {
                
                let forenames: String   //  gnt
                let surnames: String    //  fnt
            }
            
            let humanReadable: HumanReadable
            let standardised: Standardised
        }
        
        struct Vaccination {
            
            let certificateIdentifier: String   //  ci
            let country: String                 //  co
            let numberInSeriesOfDoses: Int      //  dn
            let dateOfVaccination: String       //  dt
            let certificateIssuer: String       //  is
            let vaccineManufacturer: String     //  ma
            let vaccineProduct: String          //  mp
            let overallNumberDoses: Int         //  sd
            let diseaseAgentTargeted: String    //  tg
            let vaccineProphylaxis: String      //  vp
        }
        
        let dateOfBirth: String         //  dob
        let name: Name                  //  nam
        let vaccination: Vaccination    //  v
        let version: String             //  ver
    }
    
    let data: Data          //  -260
    
    let country: String     //  1
    let validFrom: Int      //  6
    let validUntil: Int     //  4
}

extension COVIDPass: CustomStringConvertible {
    
    var description: String {
        "COVIDPass: \(data.name.humanReadable.forenames) \(data.name.humanReadable.surnames), " +
            "expires at \(Date(timeIntervalSince1970: TimeInterval(validUntil)))"
    }
}

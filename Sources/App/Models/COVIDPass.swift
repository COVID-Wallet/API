//
//  COVIDPass.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 10/08/2021.
//

import Foundation

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
        
        enum CertificateData {
            
            struct Recovery: HasCertificateData {
                
                let diseaseAgentTargeted: DiseaseAgentTargeted  //  tg
                let country: String                             //  co
                let certificateIssuer: String                   //  is
                let certificateIdentifier: String               //  ci
                
                let firstPositiveTestDate: String               //  fr
                
                let validFrom: String                           //  df
                let validUntil: String                          //  du
            }
            
            struct Test: HasCertificateData {
                
                let diseaseAgentTargeted: DiseaseAgentTargeted  //  tg
                let country: String                             //  co
                let certificateIssuer: String                   //  is
                let certificateIdentifier: String               //  ci
                
                let testType: TestType                          //  tt
                let testName: String?                           //  nm
                let testDeviceIdentifier: String                //  ma
                let testSampleCollectionDate: String            //  sc
                let testResult: TestResult                      //  tr
                let testingCentreFacility: String               //  tc
            }
            
            struct Vaccination: HasCertificateData {
                
                let diseaseAgentTargeted: DiseaseAgentTargeted  //  tg
                let country: String                             //  co
                let certificateIssuer: String                   //  is
                let certificateIdentifier: String               //  ci
                
                let numberInSeriesOfDoses: Int                  //  dn
                let dateOfVaccination: String                   //  dt
                let vaccineManufacturer: String                 //  ma
                let vaccineProduct: VaccineProduct              //  mp
                let overallNumberDoses: Int                     //  sd
                let vaccineProphylaxis: VaccineProphylaxis      //  vp
            }
            
            case recovery(Recovery)
            case test(Test)
            case vaccination(Vaccination)
        }
        
        let dateOfBirth: String                 //  dob
        let name: Name                          //  nam
        let certificateData: CertificateData    //  r / t / v
        let version: String                     //  ver
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

//
//  COVIDPass+CBORDecodable.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 10/08/2021.
//

import Foundation
import SwiftCBOR

protocol CBORDecodable {
    
    init(cborData: CBOR) throws
}

enum COVIDPassDecodeError: Error {
    
    case invalidCountry(country: String)
    case invalidPassType
    case parseError
}

extension COVIDPass: CBORDecodable {
    
    init(cborData: CBOR) throws {
        guard case let CBOR.map(map) = cborData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let one = map[.unsignedInt(1)], case let CBOR.utf8String(country) = one,
              let six = map[.unsignedInt(6)], case let CBOR.unsignedInt(validFrom) = six,
              let four = map[.unsignedInt(4)], case let CBOR.unsignedInt(validUntil) = four,
              let negative = map[.negativeInt(259)] else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard country == "PT" else {
            throw COVIDPassDecodeError.invalidCountry(country: country)
        }
        
        self.country = country
        self.validFrom = Int(validFrom)
        self.validUntil = Int(validUntil)
        
        self.data = try COVIDPass.Data(cborData: negative)
    }
}

extension COVIDPass.Data: CBORDecodable {
    
    init(cborData: CBOR) throws {
        guard case let CBOR.map(map) = cborData, let one = map[.unsignedInt(1)], case let CBOR.map(data) = one else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let dob = data[.utf8String("dob")], case let CBOR.utf8String(dateOfBirth) = dob,
              let ver = data[.utf8String("ver")], case let CBOR.utf8String(version) = ver,
              let nam = data[.utf8String("nam")] else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let v = data[.utf8String("v")] else {
            throw COVIDPassDecodeError.invalidPassType
        }
        
        self.dateOfBirth = dateOfBirth
        self.version = version
        
        self.name = try COVIDPass.Data.Name(cborData: nam)
        self.vaccination = try COVIDPass.Data.Vaccination(cborData: v)
    }
}

extension COVIDPass.Data.Name: CBORDecodable {
    
    init(cborData: CBOR) throws {
        guard case let CBOR.map(data) = cborData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let fn = data[.utf8String("fn")], case let CBOR.utf8String(surnames) = fn,
              let fnt = data[.utf8String("fnt")], case let CBOR.utf8String(standardisedSurnames) = fnt,
              let gn = data[.utf8String("gn")], case let CBOR.utf8String(forenames) = gn,
              let gnt = data[.utf8String("gnt")], case let CBOR.utf8String(standardisedForenames) = gnt else {
            throw COVIDPassDecodeError.parseError
        }
        
        self.humanReadable = HumanReadable(forenames: forenames, surnames: surnames)
        self.standardised = Standardised(forenames: standardisedForenames, surnames: standardisedSurnames)
    }
}

extension COVIDPass.Data.Vaccination: CBORDecodable {
    
    init(cborData: CBOR) throws {
        guard case let CBOR.array(array) = cborData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let data = array.last else {
            throw COVIDPassDecodeError.invalidPassType
        }
        
        guard let ci = data[.utf8String("ci")], case let CBOR.utf8String(certificateIdentifier) = ci,
              let co = data[.utf8String("co")], case let CBOR.utf8String(country) = co,
              let dn = data[.utf8String("dn")], case let CBOR.unsignedInt(numberInSeriesOfDoses) = dn,
              let dt = data[.utf8String("dt")], case let CBOR.utf8String(dateOfVaccination) = dt,
              let `is` = data[.utf8String("is")], case let CBOR.utf8String(certificateIssuer) = `is`,
              let ma = data[.utf8String("ma")], case let CBOR.utf8String(vaccineManufacturer) = ma,
              let mp = data[.utf8String("mp")], case let CBOR.utf8String(vaccineProduct) = mp,
              let sd = data[.utf8String("sd")], case let CBOR.unsignedInt(overallNumberDoses) = sd,
              let tg = data[.utf8String("tg")], case let CBOR.utf8String(diseaseAgentTargeted) = tg,
              let vp = data[.utf8String("vp")], case let CBOR.utf8String(vaccineProphylaxis) = vp else {
            throw COVIDPassDecodeError.parseError
        }
        
        self.certificateIdentifier = certificateIdentifier
        self.country = country
        self.numberInSeriesOfDoses = Int(numberInSeriesOfDoses)
        self.dateOfVaccination = dateOfVaccination
        self.certificateIssuer = certificateIssuer
        self.vaccineManufacturer = vaccineManufacturer
        self.vaccineProduct = vaccineProduct
        self.overallNumberDoses = Int(overallNumberDoses)
        self.diseaseAgentTargeted = diseaseAgentTargeted
        self.vaccineProphylaxis = vaccineProphylaxis
    }
}

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
    case invalidVaccine
    case malformedPass
    case notImplemented
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
        
        self.dateOfBirth = dateOfBirth
        self.version = version
        
        self.name = try COVIDPass.Data.Name(cborData: nam)
        self.certificateData = try COVIDPass.Data.CertificateData.init(cborData: data)
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

extension COVIDPass.Data.CertificateData {
    
    init(cborData: [CBOR: CBOR]) throws {
        if let r = cborData[.utf8String("r")] {
            self = try .init(recoveryCBORData: r)
        } else if let t = cborData[.utf8String("t")] {
            self = try .init(testCBORData: t)
        } else if let v = cborData[.utf8String("v")] {
            self = try .init(vaccineCBORData: v)
        } else {
            throw COVIDPassDecodeError.invalidPassType
        }
    }
    
    init(recoveryCBORData: CBOR) throws {
        guard case let CBOR.array(array) = recoveryCBORData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard array.count == 1, let data = array.last else {
            throw COVIDPassDecodeError.malformedPass
        }
        
        guard let ci = data[.utf8String("ci")], case let CBOR.utf8String(certificateIdentifier) = ci,
              let co = data[.utf8String("co")], case let CBOR.utf8String(country) = co,
              let `is` = data[.utf8String("is")], case let CBOR.utf8String(certificateIssuer) = `is`,
              let tg = data[.utf8String("tg")], case let CBOR.utf8String(diseaseAgentTargeted) = tg,
              
              let fr = data[.utf8String("fr")], case let CBOR.utf8String(firstPositiveTestDate) = fr,
              let df = data[.utf8String("df")], case let CBOR.utf8String(validFrom) = df,
              let du = data[.utf8String("du")], case let CBOR.utf8String(validUntil) = du else {
            throw COVIDPassDecodeError.parseError
        }
        
        let recoveryData = Recovery(diseaseAgentTargeted: diseaseAgentTargeted,
                                    country: country,
                                    certificateIssuer: certificateIssuer,
                                    certificateIdentifier: certificateIdentifier,
                                    firstPositiveTestDate: firstPositiveTestDate,
                                    validFrom: validFrom,
                                    validUntil: validUntil)
        
        self = .recovery(recoveryData)
    }
    
    init(testCBORData: CBOR) throws {
        guard case let CBOR.array(array) = testCBORData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard array.count == 1, let data = array.last else {
            throw COVIDPassDecodeError.malformedPass
        }
        
        guard let ci = data[.utf8String("ci")], case let CBOR.utf8String(certificateIdentifier) = ci,
              let co = data[.utf8String("co")], case let CBOR.utf8String(country) = co,
              let `is` = data[.utf8String("is")], case let CBOR.utf8String(certificateIssuer) = `is`,
              let tg = data[.utf8String("tg")], case let CBOR.utf8String(diseaseAgentTargeted) = tg,
              
              let tt = data[.utf8String("tt")], case let CBOR.utf8String(testType) = tt,
              let ma = data[.utf8String("ma")], case let CBOR.utf8String(testDeviceIdentifier) = ma,
              let sc = data[.utf8String("sc")], case let CBOR.utf8String(testSampleCollectionDate) = sc,
              let tr = data[.utf8String("tr")], case let CBOR.utf8String(testResult) = tr,
              let tc = data[.utf8String("tc")], case let CBOR.utf8String(testingCentreFacility) = tc else {
            throw COVIDPassDecodeError.parseError
        }
        
        let testName: String?
        
        if let tn = data[.utf8String("tn")], case let CBOR.utf8String(unwrappedTestName) = tn {
            testName = unwrappedTestName
        } else {
            testName = nil
        }
        
        let testData = Test(diseaseAgentTargeted: diseaseAgentTargeted,
                            country: country,
                            certificateIssuer: certificateIssuer,
                            certificateIdentifier: certificateIdentifier,
                            testType: testType,
                            testName: testName,
                            testDeviceIdentifier: testDeviceIdentifier,
                            testSampleCollectionDate: testSampleCollectionDate,
                            testResult: testResult,
                            testingCentreFacility: testingCentreFacility)
        
        self = .test(testData)
    }
    
    init(vaccineCBORData: CBOR) throws {
        guard case let CBOR.array(array) = vaccineCBORData else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard array.count == 1, let data = array.last else {
            throw COVIDPassDecodeError.malformedPass
        }
        
        guard let ci = data[.utf8String("ci")], case let CBOR.utf8String(certificateIdentifier) = ci,
              let co = data[.utf8String("co")], case let CBOR.utf8String(country) = co,
              let `is` = data[.utf8String("is")], case let CBOR.utf8String(certificateIssuer) = `is`,
              let tg = data[.utf8String("tg")], case let CBOR.utf8String(diseaseAgentTargeted) = tg,
              
              let dn = data[.utf8String("dn")], case let CBOR.unsignedInt(numberInSeriesOfDoses) = dn,
              let dt = data[.utf8String("dt")], case let CBOR.utf8String(dateOfVaccination) = dt,
              let ma = data[.utf8String("ma")], case let CBOR.utf8String(vaccineManufacturer) = ma,
              let mp = data[.utf8String("mp")], case let CBOR.utf8String(vaccineProduct) = mp,
              let sd = data[.utf8String("sd")], case let CBOR.unsignedInt(overallNumberDoses) = sd,
              let vp = data[.utf8String("vp")], case let CBOR.utf8String(vaccineProphylaxis) = vp else {
            throw COVIDPassDecodeError.parseError
        }
        
        guard let vaccineProduct = VaccineProduct(code: vaccineProduct),
              let vaccineProphylaxis = VaccineProphylaxis(code: vaccineProphylaxis) else {
            throw COVIDPassDecodeError.invalidVaccine
        }
        
        let vaccinationData = Vaccination(diseaseAgentTargeted: diseaseAgentTargeted,
                                          country: country,
                                          certificateIssuer: certificateIssuer,
                                          certificateIdentifier: certificateIdentifier,
                                          numberInSeriesOfDoses: Int(numberInSeriesOfDoses),
                                          dateOfVaccination: dateOfVaccination,
                                          vaccineManufacturer: vaccineManufacturer,
                                          vaccineProduct: vaccineProduct,
                                          overallNumberDoses: Int(overallNumberDoses),
                                          vaccineProphylaxis: vaccineProphylaxis)
        
        self = .vaccination(vaccinationData)
    }
}

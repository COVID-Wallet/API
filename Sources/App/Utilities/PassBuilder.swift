//
//  PassBuilder.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

class PassBuilder {
    
    struct Overrides {
        
        let doses: String?
        let language: SupportedLanguage?
        let shortName: String?
        
        static let none = Overrides(doses: nil,
                                    language: nil,
                                    shortName: nil)
    }
    
    struct GeneratedPassData {
        
        let name: String
        let type: COVIDPass.Data.CertificateData.BaseType
    }
    
    enum BuilderError: Error {
        
        case badEnvironment
        case fixUpError
        case internalError
        case jsonError
        case manifestError
        case noPassURL
        case positiveTest
        case resourceNotFound
        case signError
    }
    
    let certificateKey: String
    let covidPass: COVIDPass
    let qrCodeData: String
    let passTypeIdentifier: String
    let resourcesDirectory: String
    let teamIdentifier: String
    
    let overrides: Overrides
    
    private var passURL: URL?
    
    private var generatedPassData: GeneratedPassData?
    
    var passData: GeneratedPassData? { generatedPassData }
    
    init(withPass pass: COVIDPass,
         qrCodeData: String,
         resourcesDirectory: String,
         teamIdentifier: String,
         passTypeIdentifier: String,
         certificateKey: String,
         overrides: Overrides = .none) {
        
        self.covidPass = pass
        self.qrCodeData = qrCodeData
        self.resourcesDirectory = resourcesDirectory
        self.teamIdentifier = teamIdentifier
        self.passTypeIdentifier = passTypeIdentifier
        self.certificateKey = certificateKey
        self.overrides = overrides
    }
    
    func cleanup() {
        if let passURL = passURL {
            try? FileManager.default.removeItem(at: passURL)
            
            self.passURL = passURL
        }
    }
    
    private func generatePassTemplateURL() throws -> URL {
        let language = overrides.language ?? .portuguese
        let baseURL = URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("Templates")
        
        switch covidPass.data.certificateData {
        case .recovery:
            if covidPass.country != "PT" || language != .portuguese {
                return baseURL.appendingPathComponent("RecoveryGeneric.pass")
            } else {
                return baseURL.appendingPathComponent("RecoveryPT.pass")
            }
            
        case .test:
            if covidPass.country != "PT" || language != .portuguese {
                return baseURL.appendingPathComponent("TestGeneric.pass")
            } else {
                return baseURL.appendingPathComponent("TestPT.pass")
            }
            
        case .vaccination:
            if covidPass.country != "PT" || language != .portuguese {
                return baseURL.appendingPathComponent("VaccinationGeneric.pass")
            } else {
                return baseURL.appendingPathComponent("VaccinationPT.pass")
            }
        }
    }
    
    func buildUnsignedPass() throws {
        let passTemplateURL = try generatePassTemplateURL()
        
        passURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        guard let passURL = passURL else {
            throw BuilderError.internalError
        }
        
        try FileManager.default.copyItem(at: passTemplateURL, to: passURL)
        
        let passJSONURL = passURL.appendingPathComponent("pass.json")
        
        let passData = try Data(contentsOf: passJSONURL)
        
        guard var passJSON = try JSONSerialization.jsonObject(with: passData, options: []) as? [String: Any] else {
            throw BuilderError.resourceNotFound
        }
        
        passJSON["teamIdentifier"] = teamIdentifier
        passJSON["passTypeIdentifier"] = passTypeIdentifier
        passJSON["serialNumber"] = "\(Int(Date().timeIntervalSince1970))"
        passJSON["expirationDate"] = covidPass.expiryDatePassFormat
        
        if var barcode = passJSON["barcode"] as? [String: Any] {
            barcode["message"] = qrCodeData
            
            passJSON["barcode"] = barcode
        } else {
            throw BuilderError.jsonError
        }
        
        let language = overrides.language ?? .portuguese
        
        if var generic = passJSON["generic"] as? [String: [[String: Any]]] {
            let shortName = overrides.shortName ?? covidPass.data.name.humanReadable.shortName
            
            generic["headerFields"]![0]["value"] = covidPass.country
            
            generic["primaryFields"]![0]["value"] = shortName
            
            generic["backFields"]![0]["value"] = covidPass.data.name.humanReadable.fullName
            generic["backFields"]![1]["value"] = covidPass.expiryDatePassFormat
            generic["backFields"]![2]["value"] = covidPass.data.certificateData.certificateIdentifier
            
            switch covidPass.data.certificateData {
            case let .vaccination(vaccination):
                generic["headerFields"]![0]["value"] = overrides.doses ?? "\(vaccination.numberInSeriesOfDoses)/\(vaccination.overallNumberDoses)"
                generic["headerFields"]![1]["value"] = covidPass.country
                
                generic["secondaryFields"]![0]["value"] = covidPass.dateOfVaccinationPassFormat
                generic["secondaryFields"]![1]["value"] = covidPass.dateOfBirthPassFormat
                
                generic["auxiliaryFields"]![0]["value"] = vaccination.vaccineProphylaxis.name(language: language)
                generic["auxiliaryFields"]![1]["value"] = vaccination.vaccineProduct.name
                
                generatedPassData = .init(name: shortName, type: .vaccination)
                
            case .recovery:
                generic["secondaryFields"]![0]["value"] = covidPass.recoveryFirstPositiveDatePassFormat
                generic["secondaryFields"]![1]["value"] = covidPass.expiryDatePassFormat
                
                generic["backFields"]![1]["value"] = covidPass.dateOfBirthPassFormat
                generic["backFields"]![2]["value"] = covidPass.validFromPassFormat
                generic["backFields"]![3]["value"] = covidPass.data.certificateData.certificateIdentifier
                
                generatedPassData = .init(name: shortName, type: .recovery)
                
            case let .test(test):
                guard test.testResult == .notDetected else {
                    throw BuilderError.positiveTest
                }
                
                generic["secondaryFields"]![0]["value"] = covidPass.testSampleCollectionDatePassFormat
                generic["secondaryFields"]![1]["value"] = covidPass.expiryDatePassFormat
                
                generic["auxiliaryFields"]![0]["value"] = test.testType.name(language: language)
                generic["backFields"]![1]["value"] = covidPass.dateOfBirthPassFormat
                
                generatedPassData = .init(name: shortName, type: .test)
            }
            
            passJSON["generic"] = generic
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: passJSON, options: .prettyPrinted)
        
        guard let fixedUpJSON = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"),
              var fixedUpJSONData = fixedUpJSON.data(using: .utf8) else {
            throw BuilderError.fixUpError
        }
        
        try fixedUpJSONData.write(to: passJSONURL)
        
        guard let sha1 = SHA1.hexString(from: &fixedUpJSONData)?
                .replacingOccurrences(of: " ", with: "")
                .lowercased() else {
            throw BuilderError.manifestError
        }
        
        let manifestURL = passURL.appendingPathComponent("manifest.json")
        
        let manifestData = try Data(contentsOf: manifestURL)
        
        guard var manifestString = String(data: manifestData, encoding: .utf8) else {
            throw BuilderError.manifestError
        }
        
        manifestString = manifestString.replacingOccurrences(of: "<<pass.json.sha1>>", with: sha1)
        
        guard let manifestStringData = manifestString.data(using: .utf8) else {
            throw BuilderError.manifestError
        }
        
        try manifestStringData.write(to: manifestURL)
    }
    
    func signPass() throws {
        guard let passURL = passURL else {
            throw BuilderError.noPassURL
        }
        
        let shellCommand = "openssl smime -binary -sign -certfile \(resourcesDirectory)Certificates/WWDRCA.pem " +
            "-signer \(resourcesDirectory)/Certificates/PassCertificate.pem -inkey \(resourcesDirectory)Certificates/PassKey.pem " +
            "-in \(passURL.appendingPathComponent("manifest.json").path) -out \(passURL.appendingPathComponent("signature").path) " +
            "-outform DER -passin pass:\(certificateKey)"
        
        guard try Shell.execute(shellCommand) == "" else {
            throw BuilderError.signError
        }
    }
    
    func zipPass() throws -> URL {
        guard let passURL = passURL else {
            throw BuilderError.noPassURL
        }
        
        _ = try Shell.execute("cd \(passURL.path) && zip -r out.pkpass *")
        
        return passURL.appendingPathComponent("out.pkpass")
    }
}

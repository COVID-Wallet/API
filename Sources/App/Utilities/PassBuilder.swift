//
//  PassBuilder.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

class PassBuilder {
    
    enum BuilderError: Error {
        
        case badEnvironment
        case fixUpError
        case internalError
        case jsonError
        case manifestError
        case noPassURL
        case notImplemented
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
    
    let forceGenericTemplate: Bool
    
    private var passURL: URL?
    
    init(withPass pass: COVIDPass, qrCodeData: String, resourcesDirectory: String, teamIdentifier: String, passTypeIdentifier: String, certificateKey: String, forceGenericTemplate: Bool = false) {
        self.covidPass = pass
        self.qrCodeData = qrCodeData
        self.resourcesDirectory = resourcesDirectory
        self.teamIdentifier = teamIdentifier
        self.passTypeIdentifier = passTypeIdentifier
        self.certificateKey = certificateKey
        
        self.forceGenericTemplate = forceGenericTemplate
    }
    
    func cleanup() {
        if let passURL = passURL {
            try? FileManager.default.removeItem(at: passURL)
            
            self.passURL = passURL
        }
    }
    
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    private func passTemplateURL(pass: COVIDPass) throws -> URL {
        switch pass.data.certificateData {
        case .recovery:
            if pass.country != "PT" || forceGenericTemplate {
                throw BuilderError.notImplemented
            } else {
                return URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("Recovery.pass")
            }
            
        case .test:
            if pass.country != "PT" || forceGenericTemplate {
                throw BuilderError.notImplemented
            } else {
                return URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("Test.pass")
            }
            
        case .vaccination:
            if pass.country != "PT" || forceGenericTemplate {
                return URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("VaccinationGeneric.pass")
            } else {
                return URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("VaccinationPT.pass")
            }
        }
    }
    
    func buildUnsignedPass() throws {
        let passTemplateURL = try passTemplateURL(pass: covidPass)
        
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
        
        if var generic = passJSON["generic"] as? [String: [[String: Any]]] {
            generic["headerFields"]![0]["value"] = covidPass.country
            
            generic["primaryFields"]![0]["value"] = covidPass.data.name.humanReadable.shortName
            
            generic["secondaryFields"]![1]["value"] = covidPass.data.dateOfBirth
            
            generic["backFields"]![0]["value"] = covidPass.data.name.humanReadable.fullName
            generic["backFields"]![1]["value"] = covidPass.expiryDateHumanFormat
            generic["backFields"]![2]["value"] = covidPass.data.certificateData.certificateIdentifier
            
            switch covidPass.data.certificateData {
            case let .vaccination(vaccination):
                generic["headerFields"]![0]["value"] = "\(vaccination.numberInSeriesOfDoses)/\(vaccination.overallNumberDoses)"
                generic["headerFields"]![1]["value"] = covidPass.country
                
                generic["secondaryFields"]![0]["value"] = vaccination.dateOfVaccination
                
                generic["auxiliaryFields"]![0]["value"] = vaccination.vaccineProphylaxis.name
                generic["auxiliaryFields"]![1]["value"] = vaccination.vaccineProduct.name
                
            case let .recovery(recovery):
                generic["secondaryFields"]![0]["value"] = recovery.firstPositiveTestDate
                
                generic["backFields"]![1]["value"] = covidPass.validFromHumanFormat
                generic["backFields"]![2]["value"] = covidPass.expiryDateHumanFormat
                generic["backFields"]![3]["value"] = recovery.certificateIdentifier
                
            case let .test(test):
                guard test.testResult == .notDetected else {
                    throw BuilderError.positiveTest
                }
                
                generic["secondaryFields"]![0]["value"] = covidPass.testSampleCollectionDateHumanFormat
                
                throw BuilderError.notImplemented
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
        
        guard shell(shellCommand) == "" else {
            throw BuilderError.signError
        }
    }
    
    func zipPass() throws -> URL {
        guard let passURL = passURL else {
            throw BuilderError.noPassURL
        }
        
        _ = shell("cd \(passURL.path) && zip -r out.pkpass *")
        
        return passURL.appendingPathComponent("out.pkpass")
        
        //  TODO: Error handling!
    }
}

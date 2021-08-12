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
        case resourceNotFound
        case signError
    }
    
    let certificateKey: String
    let covidPass: COVIDPass
    let qrCodeData: String
    let resourcesDirectory: String
    let teamIdentifier: String
    
    private var passURL: URL?
    
    init(withPass pass: COVIDPass, qrCodeData: String, resourcesDirectory: String, teamIdentifier: String, certificateKey: String) {
        self.covidPass = pass
        self.qrCodeData = qrCodeData
        self.resourcesDirectory = resourcesDirectory
        self.teamIdentifier = teamIdentifier
        self.certificateKey = certificateKey
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
    
    func buildUnsignedPass() throws {
        let passTemplateURL = URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("Template.pass")
        
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
        passJSON["serialNumber"] = "\(Int(Date().timeIntervalSince1970))"
        passJSON["expirationDate"] = covidPass.expiryDatePassFormat
        
        if var barcode = passJSON["barcode"] as? [String: Any] {
            barcode["message"] = qrCodeData
            
            passJSON["barcode"] = barcode
        } else {
            throw BuilderError.jsonError
        }
        
        if var generic = passJSON["generic"] as? [String: [[String: Any]]] {
            generic["headerFields"]![0]["value"] = "\(covidPass.data.vaccination.numberInSeriesOfDoses)/\(covidPass.data.vaccination.overallNumberDoses)"
            generic["headerFields"]![1]["value"] = covidPass.country
            
            generic["primaryFields"]![0]["value"] = covidPass.shortName

            generic["secondaryFields"]![0]["value"] = covidPass.data.vaccination.dateOfVaccination
            generic["secondaryFields"]![1]["value"] = covidPass.data.dateOfBirth

            generic["auxiliaryFields"]![0]["value"] = covidPass.prophylaxisName
            generic["auxiliaryFields"]![1]["value"] = covidPass.productName

            generic["backFields"]![0]["value"] = covidPass.fullName
            generic["backFields"]![1]["value"] = covidPass.expiryDateHumanFormat
            generic["backFields"]![2]["value"] = covidPass.data.vaccination.certificateIdentifier
            
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
        
        let shellCommand = "openssl smime -binary -sign -certfile \(resourcesDirectory)Certificates/WWDRCA.pem -signer \(resourcesDirectory)/Certificates/PassCertificate.pem -inkey \(resourcesDirectory)Certificates/PassKey.pem -in \(passURL.appendingPathComponent("manifest.json").path) -out \(passURL.appendingPathComponent("signature").path) -outform DER -passin pass:\(certificateKey)"
        
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

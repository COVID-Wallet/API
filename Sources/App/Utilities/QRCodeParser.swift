//
//  QRCodeParser.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import base45_swift
import SWCompression
import SwiftCBOR

enum QRCodeParser {
    
    enum ParseError: Error {
        
        case decodingError
        case invalidData
        case invalidInnerCBOR
        case invalidOuterCBOR
    }
    
    static func parse(_ qrCode: String) throws -> COVIDPass {
        let b45Data = qrCode.replacingOccurrences(of: "HC1:", with: "")
        
        guard let zlibData = try? b45Data.fromBase45(),
              let cborData = try? ZlibArchive.unarchive(archive: zlibData) else {
            throw ParseError.invalidData
        }
        
        let decoded = try! CBORDecoder(input: [UInt8](cborData)).decodeItem()!
        
        guard case let CBOR.tagged(_, outerCBOR) = decoded else {
            throw ParseError.invalidOuterCBOR
        }
        
        guard let outerCBOR2 = outerCBOR[2], case let CBOR.byteString(innerCBORByteString) = outerCBOR2 else {
            throw ParseError.invalidInnerCBOR
        }
        
        guard let data = try? CBORDecoder(input: innerCBORByteString).decodeItem() else {
            throw ParseError.decodingError
        }
        
        return try COVIDPass(cborData: data)
    }
}

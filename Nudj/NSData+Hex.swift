//
//  NSData+Hex.swift
//  Nudj
//
//  Created by Richard Buckle on 16/02/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

extension NSData {
    func hexString() -> String {
        if self.length == 0 {
            return ""
        }
        var result = ""
        let bytes = UnsafePointer<UInt8>(self.bytes)
        for i in 0..<self.length {
            let byte = bytes[i]
            let hex = String(format: "%02x", byte)
            result += hex
        }
        return result
    }
}

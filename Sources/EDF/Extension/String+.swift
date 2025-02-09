//
//  String+.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//
import Foundation

extension String {
    public init<each T>(tuple: (repeat each T)) {
        self = withUnsafePointer(to: tuple) {
            let size = MemoryLayout<(repeat each T)>.size
            let data = Data(bytes: UnsafeRawPointer($0), count: size) + [0]
            return String(validating: data)
        }
    }
}

extension String {
    public init(validating data: Data) {
        self = data.withUnsafeBytes {
            String(
                cString: $0.baseAddress!
                    .assumingMemoryBound(to: CChar.self)
            )
        }
    }

    public init(data: Data) {
        self.init(data: data, encoding: .utf8)!
    }
}

extension String {
    var trimmedTrailingWhiteSpaces: String {
        var result = self
        let whitespaces: CharacterSet = .whitespaces
        while let last = result.last?.unicodeScalars.last, whitespaces.contains(last) {
            result.removeLast()
        }
        return result
    }
}

//
//  EDFAnnotation.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation

public struct EDFAnnotation {
    public let raw: String
}

extension EDFAnnotation {
    enum CtrlCharactor {
        static let onset: Character = "\u{15}"
        static let duration: Character = "\u{14}"
        static let separator: Character = "\u{14}"
    }
}

extension EDFAnnotation {
    public var timestamp: Double? {
        let separator = CtrlCharactor.separator
        return Double(
            raw.components(
                separatedBy: CharacterSet(charactersIn: "\(separator)")
            )[0]
        )
    }
}

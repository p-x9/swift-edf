//
//  EDFSignalInfo.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation

public struct EDFSignalInfo {
    public struct Raw {
        public let label: String
        public let transducerType: String
        public let physicalDimension: String
        public let physicalMinimum: String
        public let physicalMaximum: String
        public let digitalMinimum: String
        public let digitalMaximum: String
        public let prefiltering: String
        public let numberOfSamplesInEachDataRecord: String
        public let _reserved: String
    }

    public let raw: Raw
    public let colmun: Int
}

extension EDFSignalInfo {
    public var label: String { raw.label }
    public var transducerType: String { raw.transducerType }
    public var physicalDimension: String { raw.physicalDimension }
    public var physicalMinimum: Int { .init(raw.physicalMinimum)! }
    public var physicalMaximum: Int { .init(raw.physicalMaximum)! }
    public var digitalMinimum: Int { .init(raw.digitalMinimum)! }
    public var digitalMaximum: Int { .init(raw.digitalMaximum)! }
    public var prefiltering: String { raw.prefiltering }
    public var numberOfSamplesInEachDataRecord: Int { .init(raw.numberOfSamplesInEachDataRecord)! }
    public var _reserved: String { raw._reserved }
}

extension EDFSignalInfo {
    public var isAnnotation: Bool {
        label == "EDF Annotations"
    }
}

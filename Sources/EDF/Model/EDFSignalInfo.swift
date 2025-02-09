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
    /// signal label (e.g. EEG Fpz-Cz or Body temp)
    public var label: String { raw.label }
    /// transducer type (e.g. AgAgCl electrode)
    public var transducerType: String { raw.transducerType }
    /// physical dimension (e.g. uV or degreeC)
    public var physicalDimension: String { raw.physicalDimension }
    /// physical minimum (e.g. -500 or 34)
    public var physicalMinimum: Int { .init(raw.physicalMinimum)! }
    /// physical maximum (e.g. 500 or 40)
    public var physicalMaximum: Int { .init(raw.physicalMaximum)! }
    /// digital minimum (e.g. -2048)
    public var digitalMinimum: Int { .init(raw.digitalMinimum)! }
    /// digital maximum (e.g. 2047)
    public var digitalMaximum: Int { .init(raw.digitalMaximum)! }
    /// prefiltering (e.g. HP:0.1Hz LP:75Hz)
    public var prefiltering: String { raw.prefiltering }
    /// number of samples in each data record
    public var numberOfSamplesInEachDataRecord: Int { .init(raw.numberOfSamplesInEachDataRecord)! }
    /// reserved
    public var _reserved: String { raw._reserved }
}

extension EDFSignalInfo {
    public var isAnnotation: Bool {
        label == "EDF Annotations"
    }
}

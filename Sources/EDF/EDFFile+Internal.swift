//
//  EDFFile+Internal.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation
import FileIO

extension EDFFile {
    enum HeaderRecordField: CaseIterable {
        case label
        case transducerType
        case physicalDimension
        case physicalMinimum
        case physicalMaximum
        case digitalMinimum
        case digitalMaximum
        case prefiltering
        case numberOfSamplesInEachDataRecord
        case reserved
    }

    func elementSize(of field: HeaderRecordField) -> Int {
        switch field {
        case .label: 16
        case .transducerType: 80
        case .physicalDimension: 8
        case .physicalMinimum: 8
        case .physicalMaximum: 8
        case .digitalMinimum: 8
        case .digitalMaximum: 8
        case .prefiltering: 80
        case .numberOfSamplesInEachDataRecord: 8
        case .reserved: 32
        }
    }

    func startOffset(of field: HeaderRecordField) -> Int {
        var offset = header.layoutSize
        let numberOfSignals = header.numberOfSignals

        for _field in HeaderRecordField.allCases {
            if _field == field { return offset }
            offset += elementSize(of: _field) * numberOfSignals
        }
        return offset
    }

    func dataChunks(of field: HeaderRecordField) throws -> DataChunks {
        let offset = startOffset(of: field)
        let elementSize = elementSize(of: field)
        return try fileIO.readDataChunks(
            offset: numericCast(offset),
            chunkSize: elementSize,
            numberOfElements: header.numberOfSignals
        )
    }
}

extension EDFFile {
    func recordSize(of column: Int) throws -> Int? {
        guard column >= 0,
              column < header.numberOfSignals else {
            return nil
        }
        return Int(try numberOfSamplesInEachDataRecords[column])! * MemoryLayout<Int16>.size
    }

    func startOffsetInRecord(for column: Int) throws -> Int? {
        guard column >= 0,
              column < header.numberOfSignals else {
            return nil
        }
        let numberOfSamplesInEachDataRecords = try numberOfSamplesInEachDataRecords[0..<column]
        return numberOfSamplesInEachDataRecords.reduce(into: 0) { partialResult, _sample in
            partialResult += Int(_sample)! * MemoryLayout<Int16>.size
        }
    }
}

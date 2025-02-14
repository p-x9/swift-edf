//
//  EDFFile.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation
import FileIO
import EDFC

// Reference:
//  - https://www.edfplus.info/specs/edf.html
//  - https://www.edfplus.info/specs/edfplus.html
public final class EDFFile {
    public let url: URL

    let fileIO: MemoryMappedFile

    public var headerSize: Int {
        header.layoutSize
    }

    public var headerRecordSize: Int {
        header.headerRecordSize
    }

    public let header: EDFHeader

    public init(url: URL) throws {
        self.url = url
        self.fileIO = try .open(url: url, isWritable: false)

        let header: EDFHeader = try fileIO.read(
            offset: 0
        )
        self.header = header
    }
}

// MARK: - Header Record
extension EDFFile {
    /// signal labels (e.g. EEG Fpz-Cz or Body temp)
    public var labels: [String] {
        get throws {
            try dataChunks(of: .label).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// transducer types (e.g. AgAgCl electrode)
    public var transducerTypes: [String] {
        get throws {
            try dataChunks(of: .transducerType).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// physical dimensions (e.g. uV or degreeC)
    public var physicalDimensions: [String] {
        get throws {
            try dataChunks(of: .physicalDimension).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// physical minimums (e.g. -500 or 34)
    public var physicalMinimums: [String] {
        get throws {
            try dataChunks(of: .physicalMinimum).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// physical maximums (e.g. 500 or 40)
    public var physicalMaximums: [String] {
        get throws {
            try dataChunks(of: .physicalMaximum).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// digital minimums (e.g. -2048)
    public var digitalMinimums: [String] {
        get throws {
            try dataChunks(of: .digitalMinimum).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// digital maximums (e.g. 2047)
    public var digitalMaximums: [String] {
        get throws {
            try dataChunks(of: .digitalMaximum).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// prefilterings (e.g. HP:0.1Hz LP:75Hz)
    public var prefilterings: [String] {
        get throws {
            try dataChunks(of: .prefiltering).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// number of samples in each data records
    public var numberOfSamplesInEachDataRecords: [String] {
        get throws {
            try dataChunks(of: .numberOfSamplesInEachDataRecord).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }

    /// reserveds
    public var _reserveds: [String] {
        get throws {
            try dataChunks(of: .reserved).map {
                String(data: $0)
                    .trimmedTrailingWhiteSpaces
            }
        }
    }
}

// MARK: Signal information
extension EDFFile {
    /// Signal information for the specified column
    /// (label, transducerType, physicalDimension, ...)
    /// - Parameter column: column of singal
    /// - Returns: signal information
    public func signalInfo(for column: Int) throws -> EDFSignalInfo? {
        guard column >= 0,
              column < header.numberOfSignals else {
            return nil
        }
        let label = String(data: try dataChunks(of: .label)[column])
            .trimmedTrailingWhiteSpaces
        let transducerType = String(data: try dataChunks(of: .transducerType)[column])
            .trimmedTrailingWhiteSpaces
        let physicalDimension = String(data: try dataChunks(of: .physicalDimension)[column])
            .trimmedTrailingWhiteSpaces

        let physicalMinimum = String(data: try dataChunks(of: .physicalMinimum)[column])
                .trimmedTrailingWhiteSpaces
        let physicalMaximum = String(data: try dataChunks(of: .physicalMaximum)[column])
                .trimmedTrailingWhiteSpaces
        let digitalMinimum = String(data: try dataChunks(of: .digitalMinimum)[column])
                .trimmedTrailingWhiteSpaces
        let digitalMaximum = String(data: try dataChunks(of: .digitalMaximum)[column])
                .trimmedTrailingWhiteSpaces
        let prefiltering = String(data: try dataChunks(of: .prefiltering)[column])
            .trimmedTrailingWhiteSpaces
        let numberOfSamplesInEachDataRecord = String(data: try dataChunks(of: .numberOfSamplesInEachDataRecord)[column])
                .trimmedTrailingWhiteSpaces
        let reserved: String = String(data: try dataChunks(of: .reserved)[column])
            .trimmedTrailingWhiteSpaces

        let raw: EDFSignalInfo.Raw = .init(
            label: label,
            transducerType: transducerType,
            physicalDimension: physicalDimension,
            physicalMinimum: physicalMinimum,
            physicalMaximum: physicalMaximum,
            digitalMinimum: digitalMinimum,
            digitalMaximum: digitalMaximum,
            prefiltering: prefiltering,
            numberOfSamplesInEachDataRecord: numberOfSamplesInEachDataRecord,
            _reserved: reserved
        )

        return .init(raw: raw, colmun: column)
    }

    /// All signal informations
    public var signalInfos: [EDFSignalInfo] {
        get throws {
            try (0 ..< header.numberOfSignals).compactMap { column in
                try signalInfo(for: column)
            }
        }
    }
}

// MARK: - Data Record
extension EDFFile {
    /// Size per data record [byte]
    public var recordSize: Int {
        get throws {
            let numberOfSamplesInEachDataRecords = try numberOfSamplesInEachDataRecords
                .map{ Int($0)! }
            return MemoryLayout<Int16>.size * numberOfSamplesInEachDataRecords.reduce(0, +)
        }
    }

}

extension EDFFile {
    /// Signal for the specified column
    ///
    /// The signal is retrieved as a two-dimensional array of number of records ✖️ samples.
    ///
    /// - Parameter column: column of singal
    /// - Returns: signal
    public func signal(for column: Int) throws -> [[Int16]]? {
        guard let info = try signalInfo(for: column) else {
            return nil
        }
        guard !info.isAnnotation else { return nil }
        guard let startOffsetInRecord = try startOffsetInRecord(for: column) else {
            return nil
        }
        let numberOfSamplesInEachDataRecord = info.numberOfSamplesInEachDataRecord
        let recordSize = try recordSize
        let offset = headerRecordSize

        var records: [[Int16]] = []

        for row in 0 ..< header.numberOfRecords {
            let offset = offset + row * recordSize + startOffsetInRecord
            let samples: DataSequence<Int16> = try fileIO.readDataSequence(
                offset: numericCast(offset),
                numberOfElements: numberOfSamplesInEachDataRecord
            )
            records.append(Array(samples))
        }

        return records
    }

    /// Obtains annotations for all records, if any.
    public var annotations: [EDFAnnotation]? {
        get throws {
            let info = try (0 ..< header.numberOfSignals)
                .compactMap { try self.signalInfo(for: $0) }
                .first(where: { $0.isAnnotation })
            guard let info else { return nil }

            guard let startOffsetInRecord = try startOffsetInRecord(for: info.colmun),
                  let colmunRecordSize = try recordSize(of: info.colmun) else {
                return nil
            }
            let recordSize = try recordSize
            let offset = headerRecordSize

            var records: [String] = []

            for row in 0 ..< header.numberOfRecords {
                let offset = offset + row * recordSize + startOffsetInRecord
                let data = try fileIO.readData(
                    offset: numericCast(offset),
                    length: colmunRecordSize
                )
                records.append(String(validating: data))
            }

            return records.map {
                .init(raw: $0)
            }
        }
    }
}

extension EDFFile {
    /// Retrieves records at the specified index for the specified column signal
    /// - Parameters:
    ///   - column: column of signal
    ///   - index: index of record
    /// - Returns: Record of the specified signal
    public func record(for column: Int, at index: Int) throws -> [Int16]? {
        guard 0 <= index,
              index < header.numberOfRecords else {
            return nil
        }
        guard let info = try signalInfo(for: column) else {
            return nil
        }
        guard !info.isAnnotation else { return nil }
        guard let startOffsetInRecord = try startOffsetInRecord(for: column) else {
            return nil
        }
        let numberOfSamplesInEachDataRecord = info.numberOfSamplesInEachDataRecord
        let recordSize = try recordSize

        let offset = headerRecordSize + index * recordSize + startOffsetInRecord
        let samples: DataSequence<Int16> = try fileIO.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: numberOfSamplesInEachDataRecord
        )
        return Array(samples)
    }
    
    /// Annotation of records at the specified index
    /// - Parameter index: index of record
    /// - Returns: annotation
    public func annotation(at index: Int) throws -> EDFAnnotation? {
        let info = try (0 ..< header.numberOfSignals)
            .compactMap { try self.signalInfo(for: $0) }
            .first(where: { $0.isAnnotation })
        guard let info else { return nil }

        guard let startOffsetInRecord = try startOffsetInRecord(for: info.colmun),
              let colmunRecordSize = try recordSize(of: info.colmun) else {
            return nil
        }
        let recordSize = try recordSize

        let offset = headerRecordSize + index * recordSize + startOffsetInRecord
        let data = try fileIO.readData(
            offset: numericCast(offset),
            length: colmunRecordSize
        )
        return .init(raw: String(validating: data))
    }
}

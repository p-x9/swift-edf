//
//  EDFFile.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation
import EDFC

// Reference:
//  - https://www.edfplus.info/specs/edf.html
//  - https://www.edfplus.info/specs/edfplus.html
public final class EDFFile {
    public let url: URL

    let fileHandle: FileHandle

    public var headerSize: Int {
        header.layoutSize
    }

    public var headerRecordSize: Int {
        header.headerRecordSize
    }

    public let header: EDFHeader

    public init(url: URL) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        let header: EDFHeader = fileHandle.read(
            offset: 0
        )
        self.header = header
    }
}

// MARK: - Header Record
extension EDFFile {
    /// signal labels (e.g. EEG Fpz-Cz or Body temp)
    public var labels: [String] {
        dataChunks(of: .label).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// transducer types (e.g. AgAgCl electrode)
    public var transducerTypes: [String] {
        dataChunks(of: .transducerType).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// physical dimensions (e.g. uV or degreeC)
    public var physicalDimensions: [String] {
        dataChunks(of: .physicalDimension).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// physical minimums (e.g. -500 or 34)
    public var physicalMinimums: [String] {
        dataChunks(of: .physicalMinimum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// physical maximums (e.g. 500 or 40)
    public var physicalMaximums: [String] {
        dataChunks(of: .physicalMaximum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// digital minimums (e.g. -2048)
    public var digitalMinimums: [String] {
        dataChunks(of: .digitalMinimum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// digital maximums (e.g. 2047)
    public var digitalMaximums: [String] {
        dataChunks(of: .digitalMaximum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// prefilterings (e.g. HP:0.1Hz LP:75Hz)
    public var prefilterings: [String] {
        dataChunks(of: .prefiltering).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// number of samples in each data records
    public var numberOfSamplesInEachDataRecords: [String] {
        dataChunks(of: .numberOfSamplesInEachDataRecord).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    /// reserveds
    public var _reserveds: [String] {
        dataChunks(of: .reserved).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }
}

// MARK: Signal information
extension EDFFile {
    /// Signal information for the specified column
    /// (label, transducerType, physicalDimension, ...)
    /// - Parameter column: column of singal
    /// - Returns: signal information
    public func signalInfo(for column: Int) -> EDFSignalInfo? {
        guard column >= 0,
              column < header.numberOfSignals else {
            return nil
        }
        let label = String(data: dataChunks(of: .label)[column])
            .trimmedTrailingWhiteSpaces
        let transducerType = String(data: dataChunks(of: .transducerType)[column])
            .trimmedTrailingWhiteSpaces
        let physicalDimension = String(data: dataChunks(of: .physicalDimension)[column])
            .trimmedTrailingWhiteSpaces

        let physicalMinimum = String(data: dataChunks(of: .physicalMinimum)[column])
                .trimmedTrailingWhiteSpaces
        let physicalMaximum = String(data: dataChunks(of: .physicalMaximum)[column])
                .trimmedTrailingWhiteSpaces
        let digitalMinimum = String(data: dataChunks(of: .digitalMinimum)[column])
                .trimmedTrailingWhiteSpaces
        let digitalMaximum = String(data: dataChunks(of: .digitalMaximum)[column])
                .trimmedTrailingWhiteSpaces
        let prefiltering = String(data: dataChunks(of: .prefiltering)[column])
            .trimmedTrailingWhiteSpaces
        let numberOfSamplesInEachDataRecord = String(data: dataChunks(of: .numberOfSamplesInEachDataRecord)[column])
                .trimmedTrailingWhiteSpaces
        let reserved: String = String(data: dataChunks(of: .reserved)[column])
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
        (0 ..< header.numberOfSignals).compactMap { column in
            signalInfo(for: column)
        }
    }
}

// MARK: - Data Record
extension EDFFile {
    /// Size per data record [byte]
    public var recordSize: Int {
        let numberOfSamplesInEachDataRecords = numberOfSamplesInEachDataRecords
            .map{ Int($0)! }
        return MemoryLayout<Int16>.size * numberOfSamplesInEachDataRecords.reduce(0, +)
    }

}

extension EDFFile {
    /// Signal for the specified column
    ///
    /// The signal is retrieved as a two-dimensional array of number of records ✖️ samples.
    ///
    /// - Parameter column: column of singal
    /// - Returns: signal
    public func signal(for column: Int) -> [[Int16]]? {
        guard let info = signalInfo(for: column) else {
            return nil
        }
        guard !info.isAnnotation else { return nil }
        guard let startOffsetInRecord = startOffsetInRecord(for: column) else {
            return nil
        }
        let numberOfSamplesInEachDataRecord = info.numberOfSamplesInEachDataRecord
        let recordSize = recordSize
        let offset = headerRecordSize

        var records: [[Int16]] = []

        for row in 0 ..< header.numberOfRecords {
            let offset = offset + row * recordSize + startOffsetInRecord
            let samples: DataSequence<Int16> = fileHandle.readDataSequence(
                offset: numericCast(offset),
                numberOfElements: numberOfSamplesInEachDataRecord
            )
            records.append(Array(samples))
        }

        return records
    }

    /// Obtains annotations for all records, if any.
    public var annotations: [EDFAnnotation]? {
        let info = (0 ..< header.numberOfSignals)
            .compactMap { self.signalInfo(for: $0) }
            .first(where: { $0.isAnnotation })
        guard let info else { return nil }

        guard let startOffsetInRecord = startOffsetInRecord(for: info.colmun),
              let colmunRecordSize = recordSize(of: info.colmun) else {
            return nil
        }
        let recordSize = recordSize
        let offset = headerRecordSize

        var records: [String] = []

        for row in 0 ..< header.numberOfRecords {
            let offset = offset + row * recordSize + startOffsetInRecord
            let data = fileHandle.readData(
                offset: numericCast(offset),
                size: colmunRecordSize
            )
            records.append(String(validating: data))
        }

        return records.map {
            .init(raw: $0)
        }
    }
}

extension EDFFile {
    /// Retrieves records at the specified index for the specified column signal
    /// - Parameters:
    ///   - column: column of signal
    ///   - index: index of record
    /// - Returns: Record of the specified signal
    public func record(for column: Int, at index: Int) -> [Int16]? {
        guard 0 <= index,
              index < header.numberOfRecords else {
            return nil
        }
        guard let info = signalInfo(for: column) else {
            return nil
        }
        guard !info.isAnnotation else { return nil }
        guard let startOffsetInRecord = startOffsetInRecord(for: column) else {
            return nil
        }
        let numberOfSamplesInEachDataRecord = info.numberOfSamplesInEachDataRecord
        let recordSize = recordSize

        let offset = headerRecordSize + index * recordSize + startOffsetInRecord
        let samples: DataSequence<Int16> = fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: numberOfSamplesInEachDataRecord
        )
        return Array(samples)
    }
    
    /// Annotation of records at the specified index
    /// - Parameter index: index of record
    /// - Returns: annotation
    public func annotation(at index: Int) -> EDFAnnotation? {
        let info = (0 ..< header.numberOfSignals)
            .compactMap { self.signalInfo(for: $0) }
            .first(where: { $0.isAnnotation })
        guard let info else { return nil }

        guard let startOffsetInRecord = startOffsetInRecord(for: info.colmun),
              let colmunRecordSize = recordSize(of: info.colmun) else {
            return nil
        }
        let recordSize = recordSize

        let offset = headerRecordSize + index * recordSize + startOffsetInRecord
        let data = fileHandle.readData(
            offset: numericCast(offset),
            size: colmunRecordSize
        )
        return .init(raw: String(validating: data))
    }
}

//
//  EDFFile.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation
import EDFC

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
    public var labels: [String] {
        dataChunks(of: .label).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var transducerTypes: [String] {
        dataChunks(of: .transducerType).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var physicalDimensions: [String] {
        dataChunks(of: .physicalDimension).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var physicalMinimums: [String] {
        dataChunks(of: .physicalMinimum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var physicalMaximums: [String] {
        dataChunks(of: .physicalMaximum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var digitalMinimums: [String] {
        dataChunks(of: .digitalMinimum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var digitalMaximums: [String] {
        dataChunks(of: .digitalMaximum).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var prefilterings: [String] {
        dataChunks(of: .prefiltering).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var numberOfSamplesInEachDataRecords: [String] {
        dataChunks(of: .numberOfSamplesInEachDataRecord).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }

    public var _reserveds: [String] {
        dataChunks(of: .reserved).map {
            String(data: $0)
                .trimmedTrailingWhiteSpaces
        }
    }
}

// MARK: Signal information
extension EDFFile {
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

    public var signalInfos: [EDFSignalInfo] {
        (0 ..< header.numberOfSignals).compactMap { column in
            signalInfo(for: column)
        }
    }
}

// MARK: - Data Record
extension EDFFile {
    public var recordSize: Int {
        let numberOfSamplesInEachDataRecords = numberOfSamplesInEachDataRecords
            .map{ Int($0)! }
        return MemoryLayout<Int16>.size * numberOfSamplesInEachDataRecords.reduce(0, +)
    }

}

extension EDFFile {
    public func signal(for column: Int) -> [[Int16]]? {
        guard let info = signalInfo(for: column) else {
            return nil
        }
        guard !info.isAnnotation else { return nil }
        guard let startOffsetInColumn = startOffsetInRecord(for: column) else {
            return nil
        }
        let numberOfSamplesInEachDataRecord = info.numberOfSamplesInEachDataRecord
        let recordSize = recordSize
        let offset = headerRecordSize

        var records: [[Int16]] = []

        for row in 0 ..< header.numberOfRecords {
            let offset = offset + row * recordSize + startOffsetInColumn
            let samples: DataSequence<Int16> = fileHandle.readDataSequence(
                offset: numericCast(offset),
                numberOfElements: numberOfSamplesInEachDataRecord
            )
            records.append(Array(samples))
        }

        return records
    }

    public var annotations: [EDFAnnotation]? {
        let info = (0 ..< header.numberOfSignals)
            .compactMap { self.signalInfo(for: $0) }
            .first(where: { $0.isAnnotation })
        guard let info else { return nil }

        guard let startOffsetInColumn = startOffsetInRecord(for: info.colmun),
              let colmunRecordSize = recordSize(of: info.colmun) else {
            return nil
        }
        let recordSize = recordSize
        let offset = headerRecordSize

        var records: [String] = []

        for row in 0 ..< header.numberOfRecords {
            let offset = offset + row * recordSize + startOffsetInColumn
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

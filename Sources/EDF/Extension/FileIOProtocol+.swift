//
//  FileIOProtocol+.swift
//
//
//  Created by p-x9 on 2024/01/20.
//
//

import Foundation
import FileIO

extension FileIOProtocol {
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) throws -> DataSequence<Element> where Element: LayoutWrapper {
        let size = Element.layoutSize * numberOfElements
        var data = try readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) throws -> DataSequence<Element> {
        let size = MemoryLayout<Element>.size * numberOfElements
        var data = try readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }
}

extension FileIOProtocol {
    public func readDataChunks(
        offset: UInt64,
        chunkSize: Int,
        numberOfElements: Int
    ) throws -> DataChunks {
        let size = chunkSize * numberOfElements
        let data = try readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )

        return .init(
            data: data,
            chunkSize: chunkSize
        )
    }
}

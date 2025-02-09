//
//  FileHandle+.swift
//
//
//  Created by p-x9 on 2024/01/20.
//
//

import Foundation

extension FileHandle {
    public func readDataChunks(
        offset: UInt64,
        chunkSize: Int,
        numberOfElements: Int
    ) -> DataChunks {
        seek(toFileOffset: offset)
        let size = chunkSize * numberOfElements
        let data = readData(
            ofLength: size
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

    @_spi(Support)
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        let size = Element.layoutSize * numberOfElements
        var data = readData(
            ofLength: size
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

    @_spi(Support)
    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> {
        seek(toFileOffset: offset)
        let size = MemoryLayout<Element>.size * numberOfElements
        var data = readData(
            ofLength: size
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

    @_spi(Support)
    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        let size = entrySize * numberOfElements
        var data = readData(
            ofLength: size
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
            entrySize: entrySize
        )
    }

    @_spi(Support)
    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> {
        seek(toFileOffset: offset)
        let size = entrySize * numberOfElements
        var data = readData(
            ofLength: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            entrySize: entrySize
        )
    }
}

extension FileHandle {
    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }
}

extension FileHandle {
    @_spi(Support)
    public func readData(
        offset: UInt64,
        size: Int
    ) -> Data {
        seek(toFileOffset: offset)
        return readData(
            ofLength: size
        )
    }
}

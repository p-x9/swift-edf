//
//  EDFHeader.swift
//  swift-edf
//
//  Created by p-x9 on 2025/02/09
//  
//

import Foundation
import EDFC

public struct EDFHeader: LayoutWrapper {
    public typealias Layout = edf_header

    public var layout: Layout
}

extension EDFHeader {
    public var version: String {
        String(tuple: layout.version)
            .trimmedTrailingWhiteSpaces
    }

    public var localPatientID: String {
        String(tuple: layout.local_patient_id)
            .trimmedTrailingWhiteSpaces
    }

    /// dd.mm.yy
    public var recordingStartDate: String {
        String(tuple: layout.start_date_of_recording)
            .trimmedTrailingWhiteSpaces
    }

    /// hh.mm.ss
    public var recordingStartTime: String {
        String(tuple: layout.start_time_of_recording)
            .trimmedTrailingWhiteSpaces
    }

    public var _headerRecordSize: String {
        String(tuple: layout.header_record_size)
            .trimmedTrailingWhiteSpaces
    }

    public var headerRecordSize: Int {
        Int(_headerRecordSize)!
    }

    public var _numberOfRecords: String {
        String(tuple: layout.number_of_data_records)
            .trimmedTrailingWhiteSpaces
    }

    public var numberOfRecords: Int {
        Int(_numberOfRecords)!
    }

    public var _durationOfRecord: String {
        String(tuple: layout.duration_of_data_record)
            .trimmedTrailingWhiteSpaces
    }

    public var durationOfRecord: Double {
        Double(_durationOfRecord)!
    }

    public var _numberOfSignals: String {
        String(tuple: layout.number_of_signals)
            .trimmedTrailingWhiteSpaces
    }

    public var numberOfSignals: Int {
        Int(_numberOfSignals)!
    }
}

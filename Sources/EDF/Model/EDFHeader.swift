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
    /// version of this data format (0)
    public var version: String {
        String(tuple: layout.version)
            .trimmedTrailingWhiteSpaces
    }

    /// local patient identification
    public var localPatientID: String {
        String(tuple: layout.local_patient_id)
            .trimmedTrailingWhiteSpaces
    }

    /// local recording identification
    public var localRecodingID: String {
        String(tuple: layout.local_recording_id)
            .trimmedTrailingWhiteSpaces
    }

    /// recording start date of recording (dd.mm.yy)
    public var recordingStartDate: String {
        String(tuple: layout.start_date_of_recording)
            .trimmedTrailingWhiteSpaces
    }

    /// recording start time of recording (hh.mm.ss)
    public var recordingStartTime: String {
        String(tuple: layout.start_time_of_recording)
            .trimmedTrailingWhiteSpaces
    }

    /// number of bytes in header record (String)
    public var _headerRecordSize: String {
        String(tuple: layout.header_record_size)
            .trimmedTrailingWhiteSpaces
    }

    /// number of bytes in header record
    public var headerRecordSize: Int {
        Int(_headerRecordSize)!
    }

    /// number of data records (-1 if unknown) (String)
    public var _numberOfRecords: String {
        String(tuple: layout.number_of_data_records)
            .trimmedTrailingWhiteSpaces
    }

    /// number of data records (-1 if unknown)
    public var numberOfRecords: Int {
        Int(_numberOfRecords)!
    }

    /// duration of a data record, in seconds (String)
    public var _durationOfRecord: String {
        String(tuple: layout.duration_of_data_record)
            .trimmedTrailingWhiteSpaces
    }

    /// duration of a data record, in seconds
    public var durationOfRecord: Double {
        Double(_durationOfRecord)!
    }

    /// number of signals (ns) in data record (String)
    public var _numberOfSignals: String {
        String(tuple: layout.number_of_signals)
            .trimmedTrailingWhiteSpaces
    }

    /// number of signals (ns) in data record
    public var numberOfSignals: Int {
        Int(_numberOfSignals)!
    }
}

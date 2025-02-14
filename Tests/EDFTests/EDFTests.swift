import XCTest
@testable import EDF

final class EDFTests: XCTestCase {

    var edf: EDFFile!

    override func setUp() {
        let path = ""
        let url = URL(fileURLWithPath: path)
        edf = try! EDFFile(url: url)
    }

    func testHeader() {
        let header = edf.header
        print("Version:", header.version)
        print("Patient ID:", header.localPatientID)
        print("Record ID:", header.localRecodingID)
        print("Record Start:", header.recordingStartDate, header.recordingStartTime)

        print("Header Record Size:", header.headerRecordSize)
        print("Reserved:", String(tuple: edf.header._reserved))

        print("Number of Records:", header.numberOfRecords)
        print("Duration of Records:", header.durationOfRecord)

        print("Number of Signals:", header.numberOfSignals)
    }

    func testSignalInfo() throws {
        print("Label:", try edf.labels)
        print("Transducer Type:", try edf.transducerTypes)
        print("Physical Dimension:", try edf.physicalDimensions)
        print("Physical Minimum:", try edf.physicalMinimums)
        print("Physical Maximum:", try edf.physicalMaximums)
        print("Digital Minimum:", try edf.digitalMinimums)
        print("Digital Maximum:", try edf.digitalMaximums)
        print("Prefiltering:", try edf.prefilterings)
        print("Samples/Record:", try edf.numberOfSamplesInEachDataRecords)
        print("Reserved:", try edf._reserveds)
    }

    func testSignalInfo2() throws {
        let numberOfSignals = edf.header.numberOfSignals
        for i in 0 ..< numberOfSignals {
            guard let info = try edf.signalInfo(for: i) else {
                continue
            }
            print("[\(i)]")
            print(" Label:", info.label)
            print(" Transducer Type:", info.transducerType)
            print(" Physical Dimension:", info.physicalDimension)
            print(" Physical Minimum:", info.physicalMinimum)
            print(" Physical Maximum:", info.physicalMaximum)
            print(" Digital Minimum:", info.digitalMinimum)
            print(" Digital Maximum:", info.digitalMaximum)
            print(" Prefiltering:", info.prefiltering)
            print(" Samples/Record:", info.numberOfSamplesInEachDataRecord)
            print(" Reserved:", info._reserved)
        }
    }
}

extension EDFTests {
    func testAnnotations() throws {
        guard let annotations = try edf.annotations else {
            return
        }
        for annotation in annotations {
            print(annotation.timestamp!, annotation.raw.debugDescription)
        }
    }
}

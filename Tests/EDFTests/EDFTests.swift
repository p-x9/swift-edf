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

    func testSignalInfo() {
        print("Label:", edf.labels)
        print("Transducer Type:", edf.transducerTypes)
        print("Physical Dimension:", edf.physicalDimensions)
        print("Physical Minimum:", edf.physicalMinimums)
        print("Physical Maximum:", edf.physicalMaximums)
        print("Digital Minimum:", edf.digitalMinimums)
        print("Digital Maximum:", edf.digitalMaximums)
        print("Prefiltering:", edf.prefilterings)
        print("Samples/Record:", edf.numberOfSamplesInEachDataRecords)
        print("Reserved:", edf._reserveds)
    }

    func testSignalInfo2() {
        let numberOfSignals = edf.header.numberOfSignals
        for i in 0 ..< numberOfSignals {
            guard let info = edf.signalInfo(for: i) else {
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
    func testAnnotations() {
        guard let annotations = edf.annotations else {
            return
        }
        for annotation in annotations {
            print(annotation.timestamp!, annotation.raw.debugDescription)
        }
    }
}

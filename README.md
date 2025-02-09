# swift-edf

A Swift package for reading [EDF(European Data Format)](https://www.edfplus.info/specs/edf.html) files.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/EDF)](https://github.com/p-x9/EDF/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/EDF)](https://github.com/p-x9/EDF/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/EDF)](https://github.com/p-x9/EDF/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/EDF)](https://github.com/p-x9/EDF/)

## Usage

### Load from file

Load an edf file as follows:

```swift
let path = "Path To EDF File"
let url = URL(fileURLWithPath: path)
letedf = try! EDFFile(url: url)
```

### Header Information

Basic information about the entire file can be obtained via the header.

```swift
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
```

### Signal Metadata

To obtain information such as label names and units for a signal, write:

```swift
let column = 0
let info = edf.signalInfo(for: column)

// info.label, info.transducerType, ...
```

### Read Signal Data

To obtain the signal of a column, write

```swift
let column = 0
let signal = edf.signal(for: column)
```

The signal is acquired as a two-dimensional array, the size of which is the number of records * the number of samples.

To retrieve only a specific record of a signal, use the following statement.

```swift
let column = 0
let index = 100
let record = edf.record(for: column, at: index)
```

## License

EDF is released under the MIT License. See [LICENSE](./LICENSE)

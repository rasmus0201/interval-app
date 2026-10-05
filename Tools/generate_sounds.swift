import Foundation

struct ToneSegment {
    let frequency: Double
    let duration: Double
    let amplitude: Double
}

let sampleRate = 44_100

func writeWave(name: String, segments: [ToneSegment]) throws {
    var samples: [Int16] = []

    for segment in segments {
        let sampleCount = Int(Double(sampleRate) * segment.duration)
        for sampleIndex in 0..<sampleCount {
            let time = Double(sampleIndex) / Double(sampleRate)
            let fadeSamples = max(1, Int(Double(sampleRate) * 0.01))
            let fadeIn = min(1, Double(sampleIndex) / Double(fadeSamples))
            let fadeOut = min(1, Double(sampleCount - sampleIndex) / Double(fadeSamples))
            let envelope = min(fadeIn, fadeOut)
            let value = sin(2 * Double.pi * segment.frequency * time) * segment.amplitude * envelope
            samples.append(Int16(max(-1, min(1, value)) * Double(Int16.max)))
        }
    }

    let dataSize = samples.count * MemoryLayout<Int16>.size
    var data = Data()
    data.append(contentsOf: Array("RIFF".utf8))
    data.append(UInt32(36 + dataSize).littleEndianData)
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8))
    data.append(UInt32(16).littleEndianData)
    data.append(UInt16(1).littleEndianData)
    data.append(UInt16(1).littleEndianData)
    data.append(UInt32(sampleRate).littleEndianData)
    data.append(UInt32(sampleRate * 2).littleEndianData)
    data.append(UInt16(2).littleEndianData)
    data.append(UInt16(16).littleEndianData)
    data.append(contentsOf: Array("data".utf8))
    data.append(UInt32(dataSize).littleEndianData)
    for sample in samples {
        data.append(sample.littleEndianData)
    }

    try FileManager.default.createDirectory(
        at: URL(fileURLWithPath: "Interval/Sounds"),
        withIntermediateDirectories: true
    )
    try data.write(to: URL(fileURLWithPath: "Interval/Sounds/\(name).wav"))
}

extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}

let pause = ToneSegment(frequency: 0, duration: 0.10, amplitude: 0)
let high = ToneSegment(frequency: 880, duration: 0.14, amplitude: 0.84)
let higher = ToneSegment(frequency: 1_175, duration: 0.48, amplitude: 0.88)
let low = ToneSegment(frequency: 440, duration: 0.48, amplitude: 0.88)
let restHigh = ToneSegment(frequency: 740, duration: 0.14, amplitude: 0.84)
let restHigher = ToneSegment(frequency: 1_040, duration: 0.48, amplitude: 0.88)
let victoryPause = ToneSegment(frequency: 0, duration: 0.04, amplitude: 0)
let victoryC = ToneSegment(frequency: 523, duration: 0.12, amplitude: 0.84)
let victoryE = ToneSegment(frequency: 659, duration: 0.12, amplitude: 0.86)
let victoryG = ToneSegment(frequency: 784, duration: 0.14, amplitude: 0.88)
let victoryHighC = ToneSegment(frequency: 1_047, duration: 0.38, amplitude: 0.90)

try writeWave(name: "start-signal", segments: [high, pause, high, pause, higher])
try writeWave(name: "work-end-signal", segments: [high, pause, high, pause, low])
try writeWave(name: "rest-end-signal", segments: [restHigh, pause, restHigh, pause, restHigher])
try writeWave(name: "complete-signal", segments: [
    victoryC, victoryPause, victoryE, victoryPause, victoryG, victoryPause, victoryHighC
])
try writeWave(name: "blop", segments: [ToneSegment(frequency: 660, duration: 0.11, amplitude: 0.72)])
try writeWave(name: "silence", segments: [ToneSegment(frequency: 18, duration: 2.0, amplitude: 0.01)])

//
//  AKSampler+moreSFZ.swift
//  GameboyMIDIPlayer
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//  Edited by Evan Murray on 6/17/20.

import AudioKit

extension AKSampler {

    /// Load an SFZ at the given location
    ///
    /// Parameters:
    ///   - path: Path to the file as a string
    ///   - fileName: Name of the SFZ file
    ///
    open func loadSFZ2(path: String, fileName: String) {
        loadSFZ(url: URL(fileURLWithPath: path).appendingPathComponent(fileName))
    }

    /// Load an SFZ at the given location
    ///
    /// Parameters:
    ///   - url: File url to the SFZ file
    ///
    open func loadSFZ2(url: URL) {

        stopAllVoices()
        unloadAllSamples()

        var lowNoteNumber: MIDINoteNumber = 0
        var highNoteNumber: MIDINoteNumber = 127
        var noteNumber: MIDINoteNumber = 60
        var lowVelocity: MIDIVelocity = 0
        var highVelocity: MIDIVelocity = 127
        var sample: String = ""
        var loopMode: String = ""
        var loopStartPoint: Float32 = 0
        var loopEndPoint: Float32 = 0
        var currentHeader: String = ""

        let samplesBaseURL = url.deletingLastPathComponent()

        do {
            let data = try String(contentsOf: url, encoding: .ascii)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = String(line.trimmingCharacters(in: .whitespacesAndNewlines))
                if trimmed == "" || trimmed.hasPrefix("//") {
                    // ignore blank lines and comment lines
                    continue
                }
                if trimmed.hasPrefix("<group>") {
                    currentHeader = "group"
                }
                if trimmed.hasPrefix("<region>") {
                    lowNoteNumber = 0
                    highNoteNumber = 127
                    noteNumber = 60
                    lowVelocity = 0
                    highVelocity = 127
                    sample = ""
                    loopMode = ""
                    loopStartPoint = 0
                    loopEndPoint = 0
                    currentHeader = "region"
                }
                if currentHeader != "" {
                    if currentHeader == "region" {
                        
                        if trimmed.hasPrefix("key") {
                            noteNumber = MIDINoteNumber(trimmed.components(separatedBy: "=")[1])!
                            lowNoteNumber = noteNumber
                            highNoteNumber = noteNumber
                        } else if trimmed.hasPrefix("lokey") {
                            lowNoteNumber = MIDINoteNumber(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("hikey") {
                            highNoteNumber = MIDINoteNumber(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("pitch_keycenter") {
                            noteNumber = MIDINoteNumber(trimmed.components(separatedBy: "=")[1])!
                        }
                        
                        if trimmed.hasPrefix("lovel") {
                            print("Got the low velocity")
                            lowVelocity = MIDIVelocity(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("hivel") {
                            highVelocity = MIDIVelocity(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("loop_mode") {
                            loopMode = trimmed.components(separatedBy: "=")[1]
                        } else if trimmed.hasPrefix("loop_start") {
                            loopStartPoint = Float32(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("loop_end") {
                            loopEndPoint = Float32(trimmed.components(separatedBy: "=")[1])!
                        } else if trimmed.hasPrefix("sample") {
                            sample = trimmed.components(separatedBy: "sample=")[1]
                            print("Found a sample")
                        }
                        
                        let noteFrequency = Float(440.0 * pow(2.0, (Double(noteNumber) - 69.0) / 12.0))

                        let noteLog = "load \(noteNumber) \(noteFrequency) NN range \(lowNoteNumber)-\(highNoteNumber)"
                        AKLog("\(noteLog) vel \(lowVelocity)-\(highVelocity) \(sample)")

                        let sampleDescriptor = AKSampleDescriptor(noteNumber: Int32(noteNumber),
                                                                  noteFrequency: noteFrequency,
                                                                  minimumNoteNumber: Int32(lowNoteNumber),
                                                                  maximumNoteNumber: Int32(highNoteNumber),
                                                                  minimumVelocity: Int32(lowVelocity),
                                                                  maximumVelocity: Int32(highVelocity),
                                                                  isLooping: loopMode != "",
                                                                  loopStartPoint: loopStartPoint,
                                                                  loopEndPoint: loopEndPoint,
                                                                  startPoint: 0.0,
                                                                  endPoint: 0.0)
                        let sampleFileURL = samplesBaseURL.appendingPathComponent(sample)
                        if sample.hasSuffix(".wv") {
                            loadCompressedSampleFile(from: AKSampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                                  path: sampleFileURL.path))
                        } else {
                            if sample.hasSuffix(".aif") || sample.hasSuffix(".wav") {
                                let compressedFileURL = samplesBaseURL
                                    .appendingPathComponent(String(sample.dropLast(4) + ".wv"))
                                let fileMgr = FileManager.default
                                if fileMgr.fileExists(atPath: compressedFileURL.path) {
                                    loadCompressedSampleFile(
                                        from: AKSampleFileDescriptor(sampleDescriptor: sampleDescriptor,
                                                                     path: compressedFileURL.path))
                                } else {
                                    let sampleFile = try AKAudioFile(forReading: sampleFileURL)
                                    loadAKAudioFile(from: sampleDescriptor, file: sampleFile)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            AKLog("Could not load SFZ: \(error.localizedDescription)")
        }

        buildKeyMap()
        restartVoices()
    }
}

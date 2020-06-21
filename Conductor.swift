//
//  Conductor.swift
//  GameboyMIDIPlayer
//
//  Created by Evan Murray on 6/17/20.
//  Copyright © 2020 Evan Murray. All rights reserved.
//

import AudioKit

class Conductor {
    
    static let shared = Conductor()
    
    var sampler: MIDIPlayerInstrument
    var midiFile: AKAppleSequencer!
    var midiFileConnector: AKMIDINode!
    var importedMIDIURL: URL!
    
    init() {
        
        AKSettings.enableLogging = true
        
        AKAudioFile.cleanTempDirectory()
        
        AKSettings.bufferLength = .short
        
        sampler = MIDIPlayerInstrument()
        
        AudioKit.output = sampler
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
        
    }
    
    func playSound() {
        midiFile = AKAppleSequencer(fromURL: importedMIDIURL)
        midiFileConnector = AKMIDINode(node: sampler)
        midiFile.setGlobalMIDIOutput(midiFileConnector.midiIn)
        midiFile.play()
    }
    
    func loadSamples() {
        sampler.loadSFZ2(url: Bundle.main.url(forResource: "Gameboy", withExtension: "sfz")!)
    }
    
}

class MIDIPlayerInstrument: AKSampler {
    
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        
        DispatchQueue.main.async {
            buttonDict[Int(noteNumber) - 49]?.color = .red
        }
        
        let gqueue = DispatchQueue(label: "graphics-queue", qos: .userInteractive)
        
        gqueue.async {
            super.play(noteNumber: noteNumber, velocity: velocity)
        }
    }
    
    override func stop(noteNumber: MIDINoteNumber) {
        
        DispatchQueue.main.async {
            buttonDict[Int(noteNumber) - 49]?.color = .blue
        }
        
        let gqueue = DispatchQueue(label: "graphics-queue", qos: .userInteractive)
        
        gqueue.async {
            super.stop(noteNumber: noteNumber)
        }
        
    }
    
}

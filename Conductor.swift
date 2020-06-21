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
    
    var sampler: AKSampler
    var midiData: AKMIDIFile!
    var midiFile: AKAppleSequencer!
    var midiFileDescriptor: MIDIFileDescriptor!
    var midiFileConnector: AKMIDINode!
    var importedMIDIURL: URL!
    
    var lastMIDINote: Double!
    
    init() {
        
        AKSettings.enableLogging = true
        
        AKAudioFile.cleanTempDirectory()
        
        AKSettings.bufferLength = .short
        
        sampler = AKSampler()
        
        AudioKit.output = sampler
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
        
    }
    
    func setupMIDI() {
        midiFile = AKAppleSequencer(fromURL: importedMIDIURL)
        midiData = AKMIDIFile(url: importedMIDIURL)
        midiFileDescriptor = MIDIFileDescriptor(midiFile: midiData)
        midiFileConnector = AKMIDINode(node: sampler)
        midiFile.setGlobalMIDIOutput(midiFileConnector.midiIn)
        
        //lastMIDINote = midiFileDescriptor.finalNoteList[self.midiFileDescriptor.finalNoteList.count - 1].noteOffPosition
    }
    
    func playSound() {
        midiFile.play()
    }
    
    func loadSamples() {
        sampler.loadSFZ2(url: Bundle.main.url(forResource: "Gameboy", withExtension: "sfz")!)
    }
    
}

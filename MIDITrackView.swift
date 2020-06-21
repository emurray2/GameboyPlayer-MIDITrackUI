//
//  TrackView.swift
//  GameboyMIDIPlayer
//
//  Created by Evan Murray on 6/18/20.
//  Copyright © 2020 Evan Murray. All rights reserved.
//

import AudioKit
import AudioKitUI

//Display a MIDI Sequence in a track

class MIDITrackView: AKButton {
    
    var length: Double!
    var playbackCursorRect: CGRect!
    var playbackCursorView: UIView!
    var playbackCursorPosition: Double = 0.0
    
    /// Initialization within Interface Builder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.borderWidth = 0.0
        self.frame.size.width = CGFloat(UIScreen.main.bounds.width)
        self.frame.origin.x = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderWidth = 0.0
        self.frame.size.width = CGFloat(UIScreen.main.bounds.width)
        self.frame.origin.x = 0
    }
    
    /*func updateLength(withLength: Double) {
        playbackCursorRect = CGRect(x: 0, y: 0, width: 3, height: Double(self.frame.height))
        playbackCursorView = UIView(frame: playbackCursorRect)
        playbackCursorView.backgroundColor = .white
        self.addSubview(self.playbackCursorView)
        
        Timer.scheduledTimer(timeInterval: withLength / 100.0,
        target: self,
        selector: #selector(self.updateUI),
        userInfo: nil,
        repeats: true)
    }*/
    
    func populateViewNotes() {
        
        let noteList = conductor.midiFileDescriptor.finalNoteList
        let noteRange = conductor.midiFileDescriptor.noteRange + 1
        
        let trackHeight = Double(self.frame.size.height)
        let trackWidth = Double(self.frame.size.width)
        
        let noteHeight = Double(trackHeight / noteRange)
        let maxHeight = Double(trackHeight - noteHeight)
        
        let lastMIDINote = conductor.midiFileDescriptor.finalNoteList.count - 1
        
        var noteZoomConstant = 1.25 * trackWidth
        
        if conductor.midiFileDescriptor.finalNoteList[lastMIDINote].noteOffPosition == 128.0 {
            noteZoomConstant = 0.0078125 * trackWidth
        }
        
        if conductor.midiFileDescriptor.finalNoteList[lastMIDINote].noteOffPosition > 120 {
            noteZoomConstant = 0.00799999 * trackWidth
        }
        
        for note in 0...(conductor.midiFileDescriptor.finalNoteList.count - 1) {
            
            let noteNum = noteList[note].noteNum - conductor.midiFileDescriptor.loNote
            
            let noteStart = Double(noteList[note].noteOnPosition)
            let noteDuration = Double(noteList[note].noteDuration)
            let noteLength = Double(noteDuration * noteZoomConstant)
            
            let notePosition = Double(noteStart * noteZoomConstant)
            let noteLevel = Double(maxHeight - (noteNum * noteHeight))
            
            let noteRect = CGRect(x: notePosition, y: noteLevel, width: noteLength, height: noteHeight)
            
            let noteView = UIView(frame: noteRect)
            
            noteView.backgroundColor = self.highlightedColor
            
            self.addSubview(noteView)
        }
        
    }
    
    /*@objc func updateUI() {
        let width = Double(self.frame.width)
        playbackCursorPosition += 1
        if Double(self.playbackCursorView.frame.minX) < width {
            playbackCursorRect = CGRect(x: playbackCursorPosition, y: 0, width: 3, height: Double(self.frame.height))
            playbackCursorView.frame = playbackCursorRect
        }
    }*/
    
}

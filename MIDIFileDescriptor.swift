//
//  MIDIFileDescriptor.swift
//  GameboyMIDIPlayer
//
//  Created by Evan Murray on 6/18/20.
//  Copyright © 2020 Evan Murray. All rights reserved.
//

import AudioKit

//Keep track of the note start and end for later use

class MIDINoteTracker {
    
    var noteOnPosition = 0.0
    var noteOffPosition = 0.0
    var noteDuration = 0.0
    var noteNum = 0
    
    init(noteOnPosition: Double, noteOffPosition: Double, noteNum: Int) {
        self.noteOnPosition = noteOnPosition
        self.noteOffPosition = noteOffPosition
        self.noteDuration = noteOffPosition - noteOnPosition
        self.noteNum = noteNum
    }
}

//Get the MIDI events which occur inside a MIDI track in a MIDI file

class MIDIFileDescriptor {
    
    let midiFile: AKMIDIFile!
    let midiTrack: AKMIDIFileTrack!
    var eventCount: Int = 0
    let event: [AKMIDIEvent]!
    var noteOnList: [MIDINoteTracker] = [MIDINoteTracker]()
    var noteOffList: [MIDINoteTracker] = [MIDINoteTracker]()
    var finalNoteList: [MIDINoteTracker] = [MIDINoteTracker]()
    
    var loNote = 0
    var hiNote = 0
    var noteRange = 0
    
    init(midiFile: AKMIDIFile) {
        self.midiFile = midiFile
        print("Track Chunks:")
        print(midiFile.tracks.count)
        print("Track Chunks End")
        self.midiTrack = midiFile.tracks[0]
        self.eventCount = midiTrack.events.count
        print(self.eventCount)
        self.event = midiTrack.events
    }
    
    func getEventData(eventNum: Int) -> [MIDIByte] {
        print(event[eventNum].description)
        return event[eventNum].data
    }
    
    func getEventPosition(eventNum: Int) -> Double {
        return event[eventNum].positionInBeats!
    }
    
    func getEvents() -> [[MIDIByte]] {
        var eventList = [[MIDIByte]]()
        for event in 0...(eventCount - 1) {
            eventList.append(getEventData(eventNum: event))
        }
        return eventList
    }
    
    func getNoteEvents() {
        let eventList = getEvents()
        var eventPosition = 0.0
        var noteNum = 0
        let noteOn = 144
        let noteOff = 128
        for event in 0...(eventList.count - 1) {
            let noteEvent = eventList[event][0]
            eventPosition = 0.0
            noteNum = 0
            
            if noteEvent == noteOn {
                noteNum = Int(eventList[event][1])
                eventPosition = getEventPosition(eventNum: event)
                noteOnList.append(MIDINoteTracker(noteOnPosition: eventPosition, noteOffPosition: 0.0, noteNum: noteNum))
            }
            if noteEvent == noteOff {
                noteNum = Int(eventList[event][1])
                eventPosition = getEventPosition(eventNum: event)
                noteOffList.append(MIDINoteTracker(noteOnPosition: 0.0, noteOffPosition: eventPosition, noteNum: noteNum))
            }
            
        }
        
        //Sort list in terms of note numbers
        
        noteOnList = noteOnList.sorted(by: {$0.noteNum < $1.noteNum})
        noteOffList = noteOffList.sorted(by: {$0.noteNum < $1.noteNum})
        
        //Now we have all the note data we need
        //Put it all together in a final list
        
        for note in 0...(noteOnList.count - 1) {
            finalNoteList.append(MIDINoteTracker(noteOnPosition: noteOnList[note].noteOnPosition, noteOffPosition: noteOffList[note].noteOffPosition, noteNum: noteOffList[note].noteNum))
        }
        
        loNote = finalNoteList.min(by: {$0.noteNum < $1.noteNum})?.noteNum as! Int
        hiNote = finalNoteList.max(by: {$0.noteNum < $1.noteNum})?.noteNum as! Int
        noteRange = hiNote - loNote
        
        finalNoteList = finalNoteList.sorted(by: {$0.noteOnPosition < $1.noteOnPosition})
    }
}

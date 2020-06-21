//
//  DocumentViewController.swift
//  GameboyMIDIPlayer
//
//  Created by Evan Murray on 6/17/20.
//  Copyright © 2020 Evan Murray. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

var buttonArray: [AKButton] = [AKButton]()
var buttonDict: [Int: AKButton] = [:]

var conductor = Conductor.shared

class ViewController: UIViewController {
    
    var document: UIDocument?
    
    @IBOutlet var button49: AKButton!
    @IBOutlet var button50: AKButton!
    @IBOutlet var button51: AKButton!
    @IBOutlet var button52: AKButton!
    @IBOutlet var button53: AKButton!
    @IBOutlet var button54: AKButton!
    @IBOutlet var button55: AKButton!
    @IBOutlet var button56: AKButton!
    @IBOutlet var button57: AKButton!
    @IBOutlet var button58: AKButton!
    @IBOutlet var button59: AKButton!
    @IBOutlet var button60: AKButton!
    @IBOutlet var button61: AKButton!
    @IBOutlet var button62: AKButton!
    @IBOutlet var button63: AKButton!
    @IBOutlet var button64: AKButton!
    @IBOutlet var button65: AKButton!
    @IBOutlet var button66: AKButton!
    @IBOutlet var button67: AKButton!
    @IBOutlet var button68: AKButton!
    @IBOutlet var button69: AKButton!
    @IBOutlet var button70: AKButton!
    @IBOutlet var button71: AKButton!
    @IBOutlet var button72: AKButton!
    @IBOutlet var button73: AKButton!
    @IBOutlet var button74: AKButton!
    @IBOutlet var button75: AKButton!
    @IBOutlet var button76: AKButton!
    @IBOutlet var button77: AKButton!
    @IBOutlet var button78: AKButton!
    @IBOutlet var button79: AKButton!
    @IBOutlet var button80: AKButton!
    @IBOutlet var button81: AKButton!
    @IBOutlet var button82: AKButton!
    @IBOutlet var button83: AKButton!
    
    var noteNum = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonArray = [self.button49, self.button50, self.button51, self.button52, self.button53, self.button54, self.button55, self.button56, self.button57, self.button58, self.button59, self.button60, self.button61, self.button62, self.button63, self.button64, self.button65, self.button66, self.button67, self.button68, self.button69, self.button70, self.button71, self.button72, self.button73, self.button74, self.button75, self.button76, self.button77, self.button78, self.button79, self.button80, self.button81, self.button82, self.button83]
        
        for i in 0...(buttonArray.count - 1) {
            buttonArray[i].color = .blue
            buttonArray[i].borderWidth = 0.0
            buttonDict[i] = buttonArray[i]
        }
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                conductor.importedMIDIURL = (self.document?.fileURL)
                conductor.loadSamples()
                conductor.playSound()
                
            } else {
                print("Document Loading Failed")
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            conductor.midiFile.stop()
            self.document?.close(completionHandler: nil)
        }
    }
}

extension AKButton {
        open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            callback(self)
            transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            let noteNum = MIDINoteNumber(self.tag)
            conductor.sampler.play(noteNumber: noteNum, velocity: 127)
        }
        open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            releaseCallback(self)
            transform = CGAffineTransform.identity
            let noteNum = MIDINoteNumber(self.tag)
            conductor.sampler.stop(noteNumber: noteNum)
     }
}

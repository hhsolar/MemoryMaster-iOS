//
//  SystemAudioPlayer.swift
//  Recite
//
//  Created by apple on 20/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import AudioToolbox

class SystemAudioPlayer: NSObject {
    
    private var soundID: SystemSoundID = 0
    private var soundURL: NSURL?
    
    func playClickSound(_ name: String) {
        if SoundSwitch.shared.isSoundOn {
            loadSoundEffect(name)
            playSoundEffect()
        }
    }
    
    private func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL,&soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path: \(path)")
            }
        }
    }
    
    private func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    private func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
    
}

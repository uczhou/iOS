//
//  SoundManager.swift
//  Game
//
//  Created by Honglei Zhou on 2/9/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import AudioToolbox

/// - Attribution: iOS class
class SoundManager {
    
    // Static class variable
    static let sharedInstance = SoundManager()
    
    /// This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    /// This Method play tink sound
    func playTink() {
        
        let beepUrl = Bundle.main.url(forResource: "Tink", withExtension: "caf")!
        
        var beep: SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID(beepUrl as CFURL, &beep)
        
        AudioServicesAddSystemSoundCompletion(beep, nil, nil, {
            sound, context in
            print("Sound finished playing")
            AudioServicesRemoveSystemSoundCompletion(sound)
            AudioServicesDisposeSystemSoundID(sound)
        }, nil)
        
        AudioServicesPlaySystemSound(beep)
    }
    
    /// This Method play beep sound
    func playBeep() {
        
        let beepUrl = Bundle.main.url(forResource: "beep", withExtension: "caf")!
        
        var beep: SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID(beepUrl as CFURL, &beep)
        
        AudioServicesAddSystemSoundCompletion(beep, nil, nil, {
            sound, context in
            print("Sound finished playing")
            AudioServicesRemoveSystemSoundCompletion(sound)
            AudioServicesDisposeSystemSoundID(sound)
        }, nil)
        
        AudioServicesPlaySystemSound(beep)
    }
    
    /// This Method play win sound
    func playWin() {
        let beepUrl = Bundle.main.url(forResource: "sound", withExtension: "caf")!
        
        var beep: SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID(beepUrl as CFURL, &beep)
        
        AudioServicesAddSystemSoundCompletion(beep, nil, nil, {
            sound, context in
            print("Sound finished playing")
            AudioServicesRemoveSystemSoundCompletion(sound)
            AudioServicesDisposeSystemSoundID(sound)
        }, nil)
        
        AudioServicesPlaySystemSound(beep)
    }
}


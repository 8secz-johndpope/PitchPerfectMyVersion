//
//  AudioRecorderManager.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/27/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioRecorderManagerDelegate {
    func audioFileSetupFailure(sender: AudioRecorderManager)
    func audioPayerFinishedPlaying(sender: AudioRecorderManager)
}

class AudioRecorderManager: NSObject, AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
    }
}

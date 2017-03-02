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
    func audioRecorderFinishedRecording(sender: AudioRecorderManager, url: URL?)
}

class AudioRecorderManager: NSObject, AVAudioRecorderDelegate {
    
    var delegate: AudioRecorderManagerDelegate!
    var audioRecorder: AVAudioRecorder!
    
    // errors enum
    enum Errors: Swift.Error {
        case AudioRecorderSetupFailure(String)
    }
    
    func recordAudio() throws {
        
        // get path save recorded audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        do {
            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        } catch {
            throw Errors.AudioRecorderSetupFailure("Unable to initialize audio recorder")
        }
        
        // create audioRecorder, configure, then start recording
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
    
        guard audioRecorder != nil else {
            return
        }
        
        audioRecorder.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            delegate.audioRecorderFinishedRecording(sender: self,
                                                    url: recorder.url)
        }
        else {
            delegate.audioRecorderFinishedRecording(sender: self,
                                                    url: nil)
        }
    }
}

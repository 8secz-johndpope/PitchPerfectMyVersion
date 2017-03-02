//
//  AudioRecorderManager.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/27/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About AudioRecorderManager.swift:
 Provides functionality to record audio and return a file (URL). Also a protocol/delegate definition that allows the
 delegate to be informed when recording has finished.
 */

import Foundation
import AVFoundation

// used to inform conforming delegate when recording has completed
protocol AudioRecorderManagerDelegate {
    func audioRecorderFinishedRecording(sender: AudioRecorderManager, url: URL?)
}

class AudioRecorderManager: NSObject, AVAudioRecorderDelegate {
    
    // ref to delegate
    var delegate: AudioRecorderManagerDelegate!
    
    // ref to audioRecorder
    fileprivate var audioRecorder: AVAudioRecorder!
    
    // errors enum
    enum Errors: Swift.Error {
        case AudioRecorderSetupFailure(String)
    }
    
    // record audio
    func recordAudio() throws {
        
        // get path save recorded audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        do {
            // create audioRecorder, configure, then start recording
            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
        catch {
            throw Errors.AudioRecorderSetupFailure("Unable to initialize audio recorder")
        }
    }
    
    // stop recording
    func stopRecording() {
    
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
        }
    }
    
    // AVAudioRecorderDelegate delegate function
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // test for successful completion. Fire delegate
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

//
//  AudioPlaybackManager.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/26/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioEffects {
    case speed(Float)
    case pitch(Float)
    case echo
    case reverb
    case dry
}

protocol AudioPlaybackManagerDelegate {
    func audioFileSetupFailure(sender: AudioPlaybackManager)
    func audioPayerFinishedPlaying(sender: AudioPlaybackManager)
}

class AudioPlaybackManager: NSObject {
    
    var delegate: AudioPlaybackManagerDelegate!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    
    var playbackTimer: Timer!
    
    enum Errors: Swift.Error {
        case AudioFileSetupFailure(String)
        case AudioEngineFailure(String)
    }
    
    
    func playAudio(url: URL?, effects: [AudioEffects])  throws {
        
        // initialize (recording) audio file
        var audioFile: AVAudioFile?
        do {
            print(url!)
            audioFile = try AVAudioFile(forReading: url! as URL)
        } catch {
            throw Errors.AudioFileSetupFailure("Error retrieving file from URL")
        }
        
        guard audioFile != nil else {
            throw Errors.AudioFileSetupFailure("Unable to create valid audio file")
        }
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        
        stopAudioPlayback()
        
        audioEngine.attach(audioPlayerNode)

        // create array of audio nodes..first pull out speed and pitch
        // will ultimated be connected in audioEngine in the order of the array
        // want to ensure echo and reverb are last in nodes array
        var nodesArray:[AVAudioNode] = [audioPlayerNode]
        
        // first pull out speed and pitch
        for effect in effects {
            switch effect {
            case .speed(let value):
                let speedNode = AVAudioUnitTimePitch()
                speedNode.rate = value
                audioEngine.attach(speedNode)
                nodesArray.append(speedNode)
            case .pitch(let value):
                let pitchNode = AVAudioUnitTimePitch()
                pitchNode.rate = value
                audioEngine.attach(pitchNode)
                nodesArray.append(pitchNode)
            default:
                break;
            }
        }
        
        // next pull out echo
        for effect in effects {
            switch effect {
            case .echo:
                let echoNode = AVAudioUnitDistortion()
                echoNode.loadFactoryPreset(.multiEcho1)
                audioEngine.attach(echoNode)
                nodesArray.append(echoNode)
            default:
                break;
            }
        }
        
        // finally reverb
        for effect in effects {
            switch effect {
            case .reverb:
                let reverbNode = AVAudioUnitReverb()
                reverbNode.loadFactoryPreset(.cathedral)
                reverbNode.wetDryMix = 50
                audioEngine.attach(reverbNode)
                nodesArray.append(reverbNode)
            default:
                break;
            }
        }

        // place output node at end
        nodesArray.append((audioEngine.outputNode))

        
        // now connect the nodes
        //mainMixer.outputFormat(forBus: 0)
        let mainMixer = audioEngine.mainMixerNode
        for i in 0..<(nodesArray.count - 1) {
            audioEngine.connect(nodesArray[i], to: nodesArray[i + 1], format: mainMixer.outputFormat(forBus: 0))
        }

        //audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile!, at: nil) {

            // place UI update on main thread
            OperationQueue.main.addOperation() {
                self.stopAudioPlayback()
            }
        }
        do {
            // play the recording!
            try audioEngine.start()
            audioPlayerNode.play()
        } catch {
            throw Errors.AudioEngineFailure("Failure at AudioEnginer.start()")
        }
    }
    
    // helper function, stop audio playback
    func stopAudioPlayback() {
        
        // verify audioPlayerNode, stop
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        // verify audioEngine, stop and reset
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
}

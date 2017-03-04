//
//  AudioPlaybackManager.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/26/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About AudioPlaybackManager.swift:
 Provides functionality to playback an audio file (URL). Also, includes a enum for defining
 audio effects that can be applied, and also a protocol/delegate definition that allows the delegate
 to be informed when the audio has finished playing
*/

import Foundation
import AVFoundation

// enum for audio effects
enum AudioEffects {
    case rate(Float)    // playback rate, from 1/32 to 32
    case pitch(Float)   // in "cents" (log): octave = 1200 cents, semitome = 100 cents
    case echo
    case reverb
    case dry
}

// protocol. Used to inform end of playing in delegate
protocol AudioPlaybackManagerDelegate {
    func audioPayerDidFinishPlaying(sender: AudioPlaybackManager)
}

class AudioPlaybackManager: NSObject {
    
    // delegate
    var delegate: AudioPlaybackManagerDelegate!
    
    // AVAudio
    fileprivate var audioEngine:AVAudioEngine!
    fileprivate var audioPlayerNode: AVAudioPlayerNode!
    
    // errors enum
    enum Errors: Swift.Error {
        case AudioFileSetupFailure(String)
        case AudioEngineFailure(String)
    }
    
    // function to play audiofile url, with effects
    func playAudio(url: URL?, effects: [AudioEffects]) throws {
        
        // initialize (recording) audio file
        var file: AVAudioFile?
        do {
            file = try AVAudioFile(forReading: url! as URL)
        } catch {
            throw Errors.AudioFileSetupFailure("Error retrieving file from URL")
        }
        
        // verify good audio file
        guard let audioFile = file else {
            throw Errors.AudioFileSetupFailure("Unable to create valid audio file")
        }
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)

        // create array of audio nodes..first pull out speed and pitch
        // ..want to ensure echo and reverb are last in nodes array, respectively
        var nodesArray:[AVAudioNode] = [audioPlayerNode]
        
        // first pull out speed and pitch
        for effect in effects {
            switch effect {
            case .rate(let value):
                let speedNode = AVAudioUnitTimePitch()
                speedNode.rate = value
                audioEngine.attach(speedNode)
                nodesArray.append(speedNode)
            case .pitch(let value):
                let pitchNode = AVAudioUnitTimePitch()
                pitchNode.pitch = value
                audioEngine.attach(pitchNode)
                nodesArray.append(pitchNode)
            default:
                break;
            }
        }
        
        // next, pull out echo
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
        
        // ..and lastly, reverb
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
        
        // connect the nodes
        let mainMixer = audioEngine.mainMixerNode
        for i in 0..<(nodesArray.count - 1) {
            audioEngine.connect(nodesArray[i], to: nodesArray[i + 1], format: mainMixer.outputFormat(forBus: 0))
        }

        // schedule playback
        audioPlayerNode.scheduleFile(audioFile, at: nil) {

            // main thread.
            OperationQueue.main.addOperation() {
                /*
                 ..need to research further...
                 Audio won't playback unless this is added in the completion
                 */
                self.delegate.audioPayerDidFinishPlaying(sender: self)
                
                // ..this also works
                //self.stopAudioPlayback()
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
    
    // function, stop audio playback
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

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
    //var audioURL: URL?
    //var audioFile: AVAudioFile?
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    
    enum Errors: Swift.Error {
        case AudioFileSetupFailure(String)
        case AudioEngineFailure(String)
    }
    
    
    func playAudio(url: URL?, effects: AudioEffects...)  throws {
        
        print("playAudio")
        
        // initialize (recording) audio file
        var audioFile: AVAudioFile?
        do {
            print(url!)
            audioFile = try AVAudioFile(forReading: url! as URL)
        } catch {
            print("error with file retrieval")
            throw Errors.AudioFileSetupFailure("Error retrieving file from URL")
        }
        
        guard audioFile != nil else {
            throw Errors.AudioFileSetupFailure("Unable to create valid audio file")
        }
        
        print("playAudio..made it past guard: file: \(audioFile)")

        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        
        stopAudioPlayback()
        
        audioEngine.attach(audioPlayerNode)

        /*
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
                */
        
        // now connect the nodes
        //mainMixer.outputFormat(forBus: 0)
        let mainMixer = audioEngine.mainMixerNode
        let speedNode = AVAudioUnitTimePitch()
        speedNode.rate = 1.5
        audioEngine.attach(speedNode)
        
        audioEngine.connect(audioPlayerNode,
                            to: speedNode,
                            format: mainMixer.outputFormat(forBus: 0))
        audioEngine.connect(speedNode,
                            to: audioEngine.outputNode,
                            format: mainMixer.outputFormat(forBus: 0))

        /*
        for i in 0..<(nodesArray.count - 1) {
            audioEngine.connect(nodesArray[i], to: nodesArray[i + 1], format: mainMixer.outputFormat(forBus: 0))
        }
        */
        //audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile!, at: nil) {
            
            print("scheduleFile completion")
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                delayInSeconds = Double((audioFile!.length) - playerTime.sampleTime) / Double((audioFile!.processingFormat.sampleRate))
                
                print("delayInSeconds: \(delayInSeconds)")
            }
        }
        
        do {
            // play the recording!
            try audioEngine.start()
            audioPlayerNode.play()
        } catch {
            throw Errors.AudioEngineFailure("Failure at AudioEnginer.start()")
        }

        print("playAudio..made it past do/catch for try audioEngine start")
    }
    
    /*
    fileprivate func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: audioURL! as URL)
        } catch {
            delegate.audioFileSetupFailure(sender: self)
        }
    }
    */
    
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
    
    func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        /*
         if let stopTimer = stopTimer {
         stopTimer.invalidate()
         }
         */
        
        //configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    /*
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {

        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile!, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double((self.audioFile?.length)! - playerTime.sampleTime) / Double((self.audioFile?.processingFormat.sampleRate)!) / Double(rate)
                } else {
                    delayInSeconds = Double((self.audioFile?.length)! - playerTime.sampleTime) / Double((self.audioFile?.processingFormat.sampleRate)!)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            /*
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
             */
        }
        
        do {
            try audioEngine.start()
        } catch {
            //showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
*/
}
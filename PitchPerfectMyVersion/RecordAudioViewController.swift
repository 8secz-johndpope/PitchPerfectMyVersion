//
//  RecordAudioViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/25/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About RecordAudioViewController:
 This class provides functionaly to record audio. Handles "Record" and "Stop" buttons to initiate and
 end recording.
 */

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AudioPlaybackManagerDelegate, AudioRecorderManagerDelegate {

    // minimum time for a valid recording, in tenth's of a second
    let MINIMUM_ELAPSED_RECORD_TIME = 5
    
    // outlets to buttons and labels
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var audioLevelView: UIView!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var playbackLabel: UILabel!
    
    // ref to audioRecorderManager
    var audioRecorderManager: AudioRecorderManager!
    
    // ref to audioPlaybackManager
    var audioPlaybackManager: AudioPlaybackManager!
    
    // ref to timer. Used to track elapsed record time and update audio level
    var timer: Timer!
    var elapsedTime: Int = 0
    
    // ref to audio url
    var audioFileURL: URL?
    
    // enum for button/label states
    enum RecordState {
        case ready, recording, playback, problem
    }
    
    // for error messages

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // set buttons/labels to ready to record state
        configureDisplayState(.ready)
    }
    
    @IBAction func startRecordingButtonPressed(_ sender: UIButton) {
        
        // prepare for recording, update label message and button enable state
        configureDisplayState(.recording)
        
        // get session
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            do {
                
                try session.setActive(true)
            }
            catch {
            }
        }
        catch {
        }
        
        // create manager, set delegate
        audioRecorderManager = AudioRecorderManager()
        audioRecorderManager.delegate = self
        do {
            // begin recording, also start elapsed timer
            try audioRecorderManager.recordAudio()
            startElapsedTimer()
        }
        catch AudioRecorderManager.Errors.AudioRecorderSetupFailure(let val) {
            print(val)
        }
        catch {
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        if let audioPlaybackManager = audioPlaybackManager {
         
            audioPlaybackManager.stopAudioPlayback()
        }
        else if let audioRecorderManager = audioRecorderManager {
         
            // stop recording and update label message and button state
            audioRecorderManager.stopRecording()
            
            // invalidate timer, test for valid recording time
            timer.invalidate()
            if elapsedTime <= MINIMUM_ELAPSED_RECORD_TIME {
                elapsedTime = 0
                audioFileURL = nil
                updateElapsedTimeLabel()
            }
            
            // deactivate session
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            }
            catch {
            }
        }
    }
    
    @IBAction func playbackButtonPressed(_ sender: Any) {
        
        if let url = audioFileURL {
            audioPlaybackManager = AudioPlaybackManager()
            audioPlaybackManager.delegate = self
            try! audioPlaybackManager.playAudio(url: url, effects: [AudioEffects.echo])
            startElapsedTimer()
            
            configureDisplayState(.playback)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // prepare for segue to PlayAudioVC
        if segue.identifier == "PlayAudioSegue" {
            
            // get ref to PlayAudioVC, set url
            let controller = segue.destination as! PlayAudioViewController
            let audioRecorderURL = sender as! URL
            controller.audioRecorderURL = audioRecorderURL
        }
    }
    
    // helper to configure labels/button states
    func configureDisplayState(_ state: RecordState) {
        
        switch state {
        case .ready:
            startRecordingButton.isEnabled = true
            stopButton.isEnabled = false
            recordingStatusLabel.text = "Press to Record"
            if elapsedTime >= MINIMUM_ELAPSED_RECORD_TIME, audioFileURL != nil {
                playbackLabel.alpha = 1.0
                playbackButton.isEnabled = true
            }
            else {
                playbackLabel.alpha = 0.5
                playbackButton.isEnabled = false
            }
        case .recording:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = true
            recordingStatusLabel.text = "Recording in Progress"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
        case .playback:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = true
            recordingStatusLabel.text = "Playing Audio"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
        case .problem:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = false
            recordingStatusLabel.text = "Error recording"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
            break
        }
    }
    
    func startElapsedTimer() {
        
        elapsedTime = 0
        updateElapsedTimeLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            (timer) in
            self.elapsedTime += 1
            self.updateElapsedTimeLabel()
        }
    }
    
    func updateElapsedTimeLabel() {
        
        // form elapsed time string..elapsed time is tenth's of a second
        var timeString = "\(Int(elapsedTime % 10))"
        let seconds = Int(Float(elapsedTime) / 10.0)
        if seconds < 10 {
            timeString = "0\(seconds)." + timeString
        }
        else {
            timeString = "\(seconds)." + timeString
        }
        
        elapsedTimeLabel.text = "0'" + timeString
    }
    
    func audioPayerDidFinishPlaying(sender: AudioPlaybackManager) {
        
        timer.invalidate()
        audioPlaybackManager = nil
        configureDisplayState(.ready)
    }
    
    func audioRecorderFinishedRecording(sender: AudioRecorderManager, url: URL?) {
        
        audioFileURL = url
        timer.invalidate()
        audioRecorderManager = nil
        configureDisplayState(.ready)
    }
}

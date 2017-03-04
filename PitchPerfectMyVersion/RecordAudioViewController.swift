//
//  RecordAudioViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/25/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About RecordAudioViewController:
 Provides functionaly to record and play audio. Handles "Record" and "Stop" buttons to initiate and
 end recording/playback
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
    @IBOutlet weak var audioEffectButton: UIButton!

    // ref to audioRecorderManager and audioPlaybackManager
    var audioRecorderManager: AudioRecorderManager?
    var audioPlaybackManager: AudioPlaybackManager?
    
    // ref to timer. Used to track elapsed record time and update audio level
    var timer: Timer?
    var elapsedTime: Int = 0
    
    // ref to audio url
    var audioFileURL: URL?
    
    // ref to current playback audio effect
    var effect = AudioEffects.dry
    
    // enum for button/label states
    enum RecordState {
        case ready, recording, playback, problem
    }
    
    // for error messages
    enum Errors: Swift.Error {
        case SessionError(String)
        case RecorderError(String)
        case PlaybackError(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // set buttons/labels to ready to record state
        configureDisplayState(.ready)
        
        var image: UIImage!
        switch effect {
        case .dry:
            image = UIImage(named: "Stop")
        case .echo:
            image = UIImage(named: "Echo")
        case .reverb:
            image = UIImage(named: "Reverb")
        case .rate(let value):
            if value > 1.0 {
                image = UIImage(named: "Fast")
            }
            else {
                image = UIImage(named: "Slow")
            }
        case .pitch(let value):
            if value > 0.0 {
                image = UIImage(named: "HighPitch")
            }
            else {
                image = UIImage(named: "LowPitch")
            }
        }
        audioEffectButton.setImage(image, for: .normal)
    }
    
    // function to start recording
    @IBAction func startRecordingButtonPressed(_ sender: UIButton) {
        
        // get session
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            do {
                try session.setActive(true)
            }
            catch {
                showAlert(Errors.SessionError("Unable to set to active"))
            }
        }
        catch {
            showAlert(Errors.SessionError("Unable to set play/record category"))
        }
        
        // create manager, set delegate
        audioRecorderManager = AudioRecorderManager()
        audioRecorderManager?.delegate = self
        
        // start to record, start elapsed timer
        do {
            // begin recording, also start elapsed timer
            try audioRecorderManager?.recordAudio()
            configureDisplayState(.recording)
            startElapsedTimer()
        }
        catch AudioRecorderManager.Errors.AudioRecorderSetupFailure(let value) {
            showAlert(Errors.RecorderError(value))
        }
        catch {
            showAlert(Errors.RecorderError("Unknown record audio error"))
        }
    }
    
    // function to stop recording
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        // test for playback or recording
        if let audioPlaybackManager = audioPlaybackManager {
            
            // currently playback. Stop audio playback
            audioPlaybackManager.stopAudioPlayback()
        }
        else if let audioRecorderManager = audioRecorderManager {
         
            // stop recording and update label message and button state
            audioRecorderManager.stopRecording()
            
            // invalidate timer, test for valid recording time
            timer?.invalidate()
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
                showAlert(Errors.SessionError("Unable to set to inactive"))
            }
        }
    }
    
    // playback recorded audio
    @IBAction func playbackButtonPressed(_ sender: Any) {
        
        // tes for valid url
        if let url = audioFileURL {
            audioPlaybackManager = AudioPlaybackManager()
            audioPlaybackManager?.delegate = self
            
            // playback
            do {
                
                try audioPlaybackManager?.playAudio(url: url, effects: [effect])
                startElapsedTimer()
                configureDisplayState(.playback)
            }
            catch AudioPlaybackManager.Errors.AudioFileSetupFailure(let value) {
                showAlert(Errors.PlaybackError(value))
            }
            catch AudioPlaybackManager.Errors.AudioEngineFailure(let value) {
                showAlert(Errors.PlaybackError(value))
            }
            catch {
                showAlert(Errors.PlaybackError("Unknown audio playback error"))
            }
        }
    }
    
    // helper to configure labels/button states
    func configureDisplayState(_ state: RecordState) {
        
        switch state {
        case .ready:
            startRecordingButton.isEnabled = true
            stopButton.isEnabled = false
            recordingStatusLabel.text = "Press to Record"
            if elapsedTime >= MINIMUM_ELAPSED_RECORD_TIME, let _ = audioFileURL {
                playbackLabel.alpha = 1.0
                playbackButton.isEnabled = true
                audioEffectButton.isEnabled = true
            }
            else {
                playbackLabel.alpha = 0.5
                playbackButton.isEnabled = false
                audioEffectButton.isEnabled = false
            }
        case .recording:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = true
            recordingStatusLabel.text = "Recording in Progress"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
            audioEffectButton.isEnabled = false
        case .playback:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = true
            recordingStatusLabel.text = "Playing Audio"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
            audioEffectButton.isEnabled = false
        case .problem:
            startRecordingButton.isEnabled = false
            stopButton.isEnabled = false
            recordingStatusLabel.text = "Error recording"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
            audioEffectButton.isEnabled = false
            break
        }
    }
    
    // function to start elapsed timer
    func startElapsedTimer() {
        
        elapsedTime = 0
        updateElapsedTimeLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            (timer) in
            self.elapsedTime += 1
            self.updateElapsedTimeLabel()
        }
    }
    
    // helper function to convert elapsed timer into text string and update label
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
    
    // delegate function for AudioPlaybackManagerDelegate
    func audioPayerDidFinishPlaying(sender: AudioPlaybackManager) {
        
        timer?.invalidate()
        audioPlaybackManager = nil
        configureDisplayState(.ready)
    }
    
    // delegate function for AudioRecerderManagerDelegate
    func audioRecorderFinishedRecording(sender: AudioRecorderManager, url: URL?) {
        
        audioFileURL = url
        timer?.invalidate()
        audioRecorderManager = nil
        configureDisplayState(.ready)
    }
    
    // func to create/show alert..from error
    func showAlert(_ error: Errors) {
        
        // get a title and message string from the error enum
        var title: String!
        var message: String!
        switch error {
        case .PlaybackError(let value):
            title = "Audio playback error"
            message = value
        case .RecorderError(let value):
            title = "Audio recording error"
            message = value
        case .SessionError(let value):
            title = "Audio session error"
            message = value
        }
        
        // create alert and cancel action
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                              style: .cancel) {
                 
                                (action) in
                                // set buttons/labels back to ready condition after alert is dismissed
                                self.audioFileURL = nil
                                self.audioPlaybackManager = nil
                                self.audioRecorderManager = nil
                                self.configureDisplayState(.ready)
        }
        
        // add action, show
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func audioEffectButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AudioEffectsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AudioEffectsSegue" {
            
            let controller = segue.destination as! AudioEffectsViewController
            controller.recordAudioViewController = self
        }
    }
}

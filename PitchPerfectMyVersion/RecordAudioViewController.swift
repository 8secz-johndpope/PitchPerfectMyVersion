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
 end recording. If recording is successful, the initiates a segue to PlayAudioVC which is triggered
 is the AVAudioRecorderDelegate function "audioRecorderDidFinishRecording"
 */

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AudioPlaybackManagerDelegate, AudioRecorderManagerDelegate {

    // minimum time for a valid recording, in tenth's of a second
    let MINIMUM_ELAPSED_RECORD_TIME = 5
    
    // outlets to buttons and labels
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var audioLevelView: UIView!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var playbackLabel: UILabel!
    
    // ref to audioRecorderManager
    var audioRecorderManager: AudioRecorderManager!
    
    // ref to timer. Used to track elapsed record time and update audio level
    var timer: Timer!
    var elapsedTime: Int = 0
    
    // ref to audio url
    var audioFileURL: URL?
    
    enum RecordState {
        case ready, recording, playback, problem
    }
    
    struct Alerts {
        static let ErrorDuringRecordingTitle = "Error during recording"
        static let ErrorDuringRecordingMessage = "Unable to successfully complete recording"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
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
                return
            }
        } catch {
            return
        }
        
        audioRecorderManager = AudioRecorderManager()
        audioRecorderManager.delegate = self
        try! audioRecorderManager.recordAudio()
        
        startElapsedTimer()
    }
    
    @IBAction func playbackButtonPressed(_ sender: Any) {
        
        if let url = audioFileURL {
            let playbackManager = AudioPlaybackManager()
            playbackManager.delegate = self
            try! playbackManager.playAudio(url: url, effects: [AudioEffects.echo])
            startElapsedTimer()
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
            stopRecordingButton.isEnabled = false
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
            stopRecordingButton.isEnabled = true
            recordingStatusLabel.text = "Recording in Progress"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
        case .playback:
            startRecordingButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            recordingStatusLabel.text = "Playing Audio"
            playbackLabel.alpha = 0.5
            playbackButton.isEnabled = false
        case .problem:
            startRecordingButton.isEnabled = false
            stopRecordingButton.isEnabled = false
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
    }
    
    func audioRecorderFinishedRecording(sender: AudioRecorderManager, url: URL?) {
        
        audioFileURL = url
        timer.invalidate()
        configureDisplayState(.ready)
    }
}

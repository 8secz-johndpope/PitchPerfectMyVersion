//
//  RecordAudioViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/25/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission() {
            (granted) in
            
            if granted {
                print("permission to record was granted")
            }
            else {
                print("permission to record was not granted")
            }
        }
    }
    
    @IBAction func startRecordingButtonPressed(_ sender: UIButton) {
        
        recordingStatusLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        startRecordingButton.isEnabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecordingButtonPressed(_ sender: UIButton) {
        
        audioRecorder.stop()
        recordingStatusLabel.text = "Record Audio"
        startRecordingButton.isEnabled = true
        stopRecordingButton.isEnabled = false
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print("audioRecorderDidFinishRecording")
    }
}

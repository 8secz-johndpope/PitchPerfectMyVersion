//
//  PlayAudioViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 2/25/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class PlayAudioViewController: UIViewController {

    var audioRecorderURL: URL!
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var squirlButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setButtonsPlaybackState(readyToPlay: true)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        enum PlayButtonEffect: Int {
            case slow = 0, fast, high, low, echo, reverb
        }
        
        switch (PlayButtonEffect(rawValue: sender.tag)!) {
        case .slow:
            print("slow effect")
        case .fast:
            print("fast effect")
        case .high:
            print("high effect")
        case .low:
            print("low effect")
        case .echo:
            print("echo effect")
        case .reverb:
            print("reverb effect")
        }
        
        setButtonsPlaybackState(readyToPlay: false)
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        setButtonsPlaybackState(readyToPlay: true)
    }
    
    func setButtonsPlaybackState(readyToPlay: Bool) {
        
        snailButton.isEnabled = readyToPlay
        rabbitButton.isEnabled = readyToPlay
        squirlButton.isEnabled = readyToPlay
        vaderButton.isEnabled = readyToPlay
        echoButton.isEnabled = readyToPlay
        reverbButton.isEnabled = readyToPlay
        stopButton.isEnabled = !readyToPlay
    }
}

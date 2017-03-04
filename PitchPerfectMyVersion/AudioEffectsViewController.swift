//
//  AudioEffectsViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 3/3/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About AudioEffectsViewController:
 Provides functionaly to select an audio effect and pass on to calling VC
 */

import UIKit

class AudioEffectsViewController: UIViewController {

    // constants used in effects
    let SLOW_TALK: Float = 0.5
    let FAST_TALK: Float = 1.5
    let LOW_TALK: Float = -1000.0
    let HIGH_TALK: Float = 1000.0
    
    // ref to recordAudioVC..needed to pass effect to
    var recordAudioViewController: RecordAudioViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // action for buttons..select effect
    @IBAction func audioEffectButtonPressed(_ sender: UIButton) {
        
        // verify controller
        if let controller = recordAudioViewController {
            
            // select effect
            switch sender.tag {
            case 0:
                controller.effect = AudioEffects.rate(SLOW_TALK)
            case 1:
                controller.effect = AudioEffects.rate(FAST_TALK)
            case 2:
                controller.effect = AudioEffects.pitch(HIGH_TALK)
            case 3:
                controller.effect = AudioEffects.pitch(LOW_TALK)
            case 4:
                controller.effect = AudioEffects.echo
            case 5:
                controller.effect = AudioEffects.reverb
            default:
                controller.effect = AudioEffects.dry
                
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

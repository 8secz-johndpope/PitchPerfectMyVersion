//
//  AudioEffectsViewController.swift
//  PitchPerfectMyVersion
//
//  Created by Online Training on 3/3/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class AudioEffectsViewController: UIViewController {

    var recordAudioViewController: RecordAudioViewController?
    
    enum Effect: Int {
        case slow = 0, fast, high, low, echo, reverb, dry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func audioEffectButtonPressed(_ sender: UIButton) {
        
        if let controller = recordAudioViewController {
            
            switch sender.tag {
            case 0:
                controller.effect = AudioEffects.rate(0.5)
            case 1:
                controller.effect = AudioEffects.rate(1.5)
            case 2:
                controller.effect = AudioEffects.pitch(1000.0)
            case 3:
                controller.effect = AudioEffects.pitch(-1000.0)
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

//
//  AudioPlayerViewController.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit

class AudioPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func backAction(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func playAudioAction(sender: AnyObject) {
        
        
        dbprintln("")
    }
    
    @IBAction func nextAudioAction(sender: AnyObject) {
        
    }

    
}

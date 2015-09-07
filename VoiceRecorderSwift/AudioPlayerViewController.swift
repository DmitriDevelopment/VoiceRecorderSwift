//
//  AudioPlayerViewController.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var audioSlider : UISlider!
    @IBOutlet weak var audioLengthLabel : UILabel!
    @IBOutlet weak var audioRemainLengthLabel : UILabel!
    @IBOutlet weak var audioNameLabel : UILabel!
    @IBOutlet weak var playPauseBtn : UIButton!
    
    lazy var directoryURL : NSURL = {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let directiryURL = NSURL(fileURLWithPath: docsDir)!
        return directiryURL
        }()
    
    
    var audioPlayer : AVAudioPlayer!
    
    var audioList = AudioList.sharedInstance
    var currentIndex : Int = 0
    
    var timer : NSTimer!
    
    var previousPlayingTime : Double = 0
    var previousPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setupAudioPlayer()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beginInterruption:", name: AVAudioSessionInterruptionNotification, object: nil)
        
        var error : NSError?
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &error)
        audioSession.setActive(true, error: &error)
        
        if error != nil {
            dbprintln("Error activate audio session: \(error?.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAudioAction(NSNull)
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Audio Player Lifecycle
    
    func setupAudioPlayer() {
        let audioItem = self.audioList.items[currentIndex] as! AudioItem
        self.audioNameLabel.text = audioItem.title
        
        let audioTotalSecond = "00:00:00"
        audioRemainLengthLabel.text = "-\(audioItem.length)"
        
        
        let audioFileURL = self.directoryURL.URLByAppendingPathComponent("\(audioItem.title).caf")
        
        self.timer?.invalidate()
        self.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileURL, error: nil)
        self.audioPlayer.delegate = self
        self.audioPlayer.volume = 1.0
        self.audioPlayer.prepareToPlay()
        
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = Float(self.audioPlayer.duration)
        audioSlider.continuous = true
        audioSlider.value = 0.0
    }
    
    
    
    
    func playPausePlayer() {
        
        if self.audioPlayer.playing {
            playPauseBtn.setTitle("Play Audio", forState: UIControlState.Normal)
            self.audioPlayer.pause()
            self.timer?.invalidate()
        } else {
            self.audioPlayer.play()
            playPauseBtn.setTitle("Pause Audio", forState: UIControlState.Normal)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "runUIIteraction", userInfo: nil, repeats: true)
        }

    }
    
    
    func runUIIteraction() {
        
        
        self.audioSlider.value = Float(self.audioPlayer.currentTime)
        
        self.setTimeLabelsValues()
        
    }
    
    // MARK: - UI Labels
    
    func setTimeLabelsValues() {
        
        let currentTime = self.audioPlayer.currentTime
        let duration = self.audioPlayer.duration
        
        audioLengthLabel.text = convertCurrentTimeToString(currentTime, duration: duration, current: true)
        audioRemainLengthLabel.text = convertCurrentTimeToString(currentTime, duration: duration, current: false)
        
    }
    
    func convertCurrentTimeToString(currentTime : Double, duration : Double, current : Bool) -> String {
        
        var secondsCount =  current ? Int(currentTime) : Int(duration - currentTime)
        
        let sec = secondsCount % secondsInMinute
        let minute = (secondsCount % (secondsInMinute * secondsInMinute)) / secondsInMinute
        let hour = secondsCount / (secondsInMinute * secondsInMinute)
        let minus = current ? "" : "-"
        
        return NSString(format: "%@%02d:%02d:%02d", minus, hour, minute, sec) as String
    }
    
    
    // MARK: - Actions

    @IBAction func audioSliderValueChanged(sender: AnyObject) {
        
        let value = Double((sender as! UISlider).value)
        self.audioPlayer.currentTime = value
        self.setTimeLabelsValues()
        
    }
    
    
    
    @IBAction func backAction(sender: AnyObject) {
        
        self.stopAudioAction(NSNull)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func playAudioAction(sender: AnyObject) {
        
        self.playPausePlayer()
        
    }
    
    @IBAction func stopAudioAction(sender: AnyObject) {
        
        playPauseBtn.setTitle("Play Audio", forState: UIControlState.Normal)
        self.audioPlayer?.stop()
        self.audioPlayer?.currentTime = 0
        self.timer?.invalidate()
        self.runUIIteraction()
        
    }
    
    @IBAction func nextAudioAction(sender: AnyObject) {
        self.currentIndex++
        if currentIndex >= self.audioList.items.count {
            currentIndex = 0
        }
        self.setupAudioPlayer()
        self.playPausePlayer()
    }
    
    // MARK: - AudioSessionInterruptions
    
    func beginInterruption(notification : NSNotification) {
        let which : AnyObject? = notification.userInfo?[AVAudioSessionInterruptionTypeKey]
        if which != nil {
            if let began = which! as? UInt {
                if began == 0 {
                    dbprintln("end")
                    self.audioPlayer.currentTime = self.previousPlayingTime
                    if previousPlaying { self.playPausePlayer() }

                } else {
                    dbprintln("began")
                    previousPlayingTime = self.audioPlayer.currentTime
                    playPauseBtn.setTitle("Play Audio", forState: UIControlState.Normal)
                    previousPlaying = audioPlayer.playing
                    
                }
            }
        }
        
    }
    
    

    
}


extension AudioPlayerViewController : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if flag {
            self.nextAudioAction(NSNull)
        }
    }
    
    
}



























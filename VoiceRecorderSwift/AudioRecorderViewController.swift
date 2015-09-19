//
//  AudioRecorderViewController.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController {
    
    @IBOutlet weak var saveAudioButton: UIButton!
    @IBOutlet weak var stopAudioButton: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var audioProgressBar : UIProgressView!
    @IBOutlet weak var recordTimeLabel : UILabel!
    
    lazy var recordURL : NSURL = {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let docsDir = dirPaths[0] 
        
        let soundDirectoryURL = NSURL(fileURLWithPath: docsDir)
        let soundFileURL = soundDirectoryURL.URLByAppendingPathComponent("1201℀temporary_record℀1021.caf")
        return soundFileURL
        }()
    
    var progressTimer : NSTimer!
    var timeTimer : NSTimer!
    
    var audioRecorder : AVAudioRecorder!
    var audioItemList = AudioList.sharedInstance
    
    var isRecordingAvaible : Bool = false {
        didSet {
            setButtonsState()
        }
    }
    var isRecordSaved : Bool = true {
        didSet {
            setButtonsState()
        }
    }

    var isRecording : Bool = false {
        didSet {
            setButtonsState()
        }
    }
    
    
    var secondCount : Int = 0
    var totalSeconds : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beginInterruption:", name: AVAudioSessionInterruptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterBackground:", name: UIApplicationWillResignActiveNotification, object: nil)
        self.setupAudioSession()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.stopRecordAction(NSNull)
        self.progressTimer?.invalidate()
        self.timeTimer?.invalidate()
        
    }
    
    
    func setButtonsState() {
        
        self.nameTextField.userInteractionEnabled = isRecordingAvaible && !isRecording
        self.recordAudioButton.enabled = isRecordingAvaible && !isRecording
        self.saveAudioButton.enabled = !isRecordSaved && !isRecording
        self.stopAudioButton.enabled = isRecording
        
    }

    
    
    // MARK: - Actions

    @IBAction func backAction(sender: AnyObject) {
        
        self.deleteAudioRecordFile()
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func recordAction(sender: AnyObject) {
        
        if self.isFileNamePermissible() {
            
            if self.setupRecord() {
                self.isRecordSaved = false
                self.isRecording = true
                self.nameTextField.resignFirstResponder()
                if !self.audioRecorder.recording {
                    self.audioRecorder.record()
                    recordTimeLabel.text = "00:00:00"
                    self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "progressBarAction", userInfo: nil, repeats: true)
                    self.timeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeTimerAction", userInfo: nil, repeats: true)
                }
                
            }
        }
        
    }
    
    @IBAction func stopRecordAction(sender: AnyObject) {
        
        if let audioRecorder = self.audioRecorder {
            if audioRecorder.recording {
                
                self.progressTimer?.invalidate()
                self.timeTimer?.invalidate()
                
                
                self.audioRecorder.stop()
                self.audioRecorder.meteringEnabled = false
                
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(false)
                } catch let error as NSError {
                    dbprint("error : \(error.localizedDescription)")
                }
                
                self.totalSeconds = self.secondCount
                secondCount = 0;
                
                self.audioProgressBar.progress = 0
                self.isRecording = false
                
                dbprint("stop recording...")
                
            }
        }
    }
    
    @IBAction func saveAudioAction(sender: AnyObject) {
        
        if self.isFileNamePermissible() && self.totalSeconds > 0 {
            
            let timeStamp = NSDate().timeIntervalSince1970
            let audioItem = AudioItem()
            
            let name = NSString(string: nameTextField.text!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            audioItem.title = name
            audioItem.length = self.recordTimeLabel.text!
            audioItem.totalSeconds = "\(self.totalSeconds)"
            audioItem.savedTime = "\(timeStamp)"
            
            self.isRecordSaved = true
            self.audioItemList.addNewItem(audioItem, sourceFileURL: self.recordURL)
            self.backAction(NSNull)
            
        }
    }
    
    func progressBarAction() {
        self.audioRecorder.updateMeters()
        let peakPowerForChannel = pow(10,(0.05 * self.audioRecorder.peakPowerForChannel(0)))
        
        if (peakPowerForChannel <= 1.0) {
            audioProgressBar.progress = peakPowerForChannel
        }
        
        
    }
    
    
    func timeTimerAction() {
        
        secondCount++
        
        let sec = secondCount % secondsInMinute
        let minute = (secondCount % (secondsInMinute * secondsInMinute)) / secondsInMinute
        let hour = secondCount / (secondsInMinute * secondsInMinute)
        
        recordTimeLabel.text = NSString(format: "%02d:%02d:%02d", hour, minute, sec) as String
    }

    
    func enterBackground(notification : NSNotification) {
        self.stopRecordAction(NSNull)
    }
    
    
    // MARK: - Audio Record Setup
    
    func setupAudioSession() {
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            dbprint("audioSession error: \(error.localizedDescription)")
        }
        
        
        let microPhoneStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeAudio)
        
        switch microPhoneStatus {
        case .Authorized:
            // Has access
            if audioSession.inputAvailable  {
                self.isRecordingAvaible = true
                
            } else {
                
                self.showAlertController("Warning", message: "Audio input hardware not available")
                
            }
        case .Denied:
            // Microphone disabled in settings
            let alert = UIAlertController(title: "Microphone disabled in settings", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action : UIAlertAction) -> Void in
                self.isRecordingAvaible = false
            }))
            alert.addAction(UIAlertAction(title: "Open settings", style: UIAlertActionStyle.Default, handler: { (action : UIAlertAction!) -> Void in
                let settingsURL = NSURL(fileURLWithPath: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(settingsURL)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        case .Restricted:
            // Microphone accsee restricted by parental controls etc
            self.isRecordingAvaible = false
            
        case .NotDetermined:
            // Didn't request access yet
            audioSession.requestRecordPermission { [unowned self] (success : Bool) -> Void in
                self.isRecordingAvaible = success
            }
        }
   
        
    }
    
    func setupRecord() -> Bool {
        
        let soundFileURL = self.recordURL
        
        let recordSettings  =  [
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderBitRateKey: 128000,
            AVLinearPCMBitDepthKey : 16,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVSampleRateKey: 44100.0]

        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch let error as NSError {
            dbprint("error : \(error.localizedDescription)")
        }

        do {
            audioRecorder = try AVAudioRecorder(URL: soundFileURL, settings: recordSettings)
        } catch let error as NSError {
            audioRecorder = nil
            dbprint("error : \(error.localizedDescription)")
            return false
        }
        self.audioRecorder.meteringEnabled = true
        
        
        audioRecorder?.prepareToRecord()
        return true
        
        
    }
    
    
    // MARK: - AudioSessionInterruptions
    
    func beginInterruption(notification : NSNotification) {
        let which : AnyObject? = notification.userInfo?[AVAudioSessionInterruptionTypeKey]
        if which != nil {
            if let began = which! as? UInt {
                if began == 0 {
                    dbprint("end")
                } else {
                    dbprint("began")
                    self.stopRecordAction(NSNull)
                }
            }
        }
        
    }
    
    
    
    // MARK: - Helpers
    
    private func isFileNamePermissible() -> Bool {
        
        if !self.nameTextField.text!.isEmpty {
            if audioItemList.isItemExistWithName(self.nameTextField.text!) {
                self.showAlertController("Warning", message: "Audio name already exist! Please choose another.")
                return false
            }
            
        } else {
            self.showAlertController("Warning", message: "Please set recording audio name first.")
            return false
        }
        
        return true
        
    }
    
    
    private func showAlertController(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    private func deleteAudioRecordFile() {
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(self.recordURL.path!) {
            do {
                try fileManager.removeItemAtPath(self.recordURL.path!)
            } catch let error as NSError {
                dbNSLog("Could not delete file -:\(error.localizedDescription)")
            }
        } else {
            dbNSLog("file doesn't exist in document directory")
        }
        
        
    }
    

}


extension AudioRecorderViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.isFileNamePermissible() {
            textField.resignFirstResponder()
        }
        return true
    }
}














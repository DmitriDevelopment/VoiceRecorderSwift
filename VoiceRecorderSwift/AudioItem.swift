//
//  AudioItem.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import Foundation


class AudioItem : NSObject, DictionaryConvertable {
    
    var title : String = ""
    var length : String = ""
    var totalSeconds : String = ""
    var savedTime : String = ""
    
    
    required override init() {
        super.init()
    }
    
    convenience required init?(fromDict dict: NSDictionary) {
        self.init()
        if let audioName = dict.objectForKey(kAudioNameKey) as? String {
            
            title = audioName
            length = dict.objectForKey(kAudioLengthKey) as? String ?? ""
            totalSeconds = dict.objectForKey(kAudioTotalSecondsKey) as? String ?? ""
            savedTime = dict.objectForKey(kAudioSavedTimeKey) as? String ?? ""
            
        } else {
            return nil
        }
    }
    
    
    // encode method
    
    func encodeToDictionary() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        dict.setValue(NSString(string: self.title), forKey: kAudioNameKey)
        dict.setValue(NSString(string: self.length), forKey: kAudioLengthKey)
        dict.setValue(NSString(string: self.totalSeconds), forKey: kAudioTotalSecondsKey)
        dict.setValue(NSString(string: self.savedTime), forKey: kAudioSavedTimeKey)
        
        return dict
    }
    
    
    
}

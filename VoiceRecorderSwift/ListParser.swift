//
//  ListParser.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import Foundation

protocol DictionaryConvertable : NSObjectProtocol {
    init?(fromDict : NSDictionary)
    func encodeToDictionary() -> NSDictionary
}

// test changes
// new feature brunch
// new
class ListParser<ParsedItem : DictionaryConvertable >: NSObject {
    
    
    /**  Parse List from UserDefaults. */
    func parseListFromUserDefaults() -> [ParsedItem] {
        
        var list : [ParsedItem] = []
        if let arrayList = NSUserDefaults.standardUserDefaults().objectForKey(kSaveRecordedAudioListKey) as? NSArray {
            
            for object in arrayList {
                if let object = object as? NSDictionary {
                    if let item = ParsedItem.init(fromDict: object) {
                        list.append(item)
                    }
                }
            }
        }
        
        return list
    }

    
    /** Syncronize data with User Defaults */
    func synchronizeData(items : [ParsedItem]) {
        
        let savedArray = NSMutableArray()
        for item in items {
            let dictionaryItem = item.encodeToDictionary()
            savedArray.addObject(dictionaryItem)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(savedArray, forKey: kSaveRecordedAudioListKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    
    
    
}

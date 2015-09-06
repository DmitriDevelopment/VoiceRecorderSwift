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


class ListParser: NSObject {
    
    
    /**  Parse List from UserDefaults. */
    func parseListFromUserDefaults<T : DictionaryConvertable >(convertedClass : T.Type) -> [DictionaryConvertable] {
        
        var list : [DictionaryConvertable] = []
        if let arrayList = NSUserDefaults.standardUserDefaults().objectForKey(kSaveRecordedAudioListKey) as? NSArray {
            
            for object in arrayList {
                if let object = object as? NSDictionary {
                    if let item = convertedClass(fromDict: object) {
                        list.append(item)
                    }
                }
            }
        }
        
        return list
    }

    
    /** Syncronize data with User Defaults */
    func synchronizeData(items : [DictionaryConvertable]) {
        
        var savedArray = NSMutableArray()
        for item in items {
            let dictionaryItem = item.encodeToDictionary()
            savedArray.addObject(dictionaryItem)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(savedArray, forKey: kSaveRecordedAudioListKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    
    
    
}

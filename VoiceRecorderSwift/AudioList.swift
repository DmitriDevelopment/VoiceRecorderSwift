//
//  AudioList.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import Foundation

protocol AudioListDelegate : class {
    func deleteFile(name : String, success : Bool)
}

class AudioList  {
    
    static let sharedInstance = AudioList()
    
    private  (set)var items : [DictionaryConvertable]
    
    private var parser = ListParser()
    
    weak var delegate : AudioListDelegate!
    
    private init() {
        items = parser.parseListFromUserDefaults(AudioItem)
    }
    
    // MARK: - Public methods
    
    func isItemExistWithName( name : String ) -> Bool {
        var exist = false
        let items = self.convertItemsToAudioItems()
        if !items.filter( { $0.title == name } ).isEmpty {
            exist = true
            return exist
        }
        
        return exist
    }

    
    func addNewItem(newItem : AudioItem) {
        
        // If we have item with the same name then replace otherwise add new
        let items = self.convertItemsToAudioItems()
        
        if !items.filter({ $0.title == newItem.title }).isEmpty {
            var oldIndex : Int?
            for (index, item) in enumerate(items) {
                if item.title == newItem.title {
                    oldIndex = index
                }
            }
            
            if let index = oldIndex {
                
                let range = Range(start: index, end: index)
                let newItem = newItem as DictionaryConvertable
                self.items.replaceRange(range, with: [newItem])
                
            }
        } else {
            self.items.append(newItem)
        }
        
        
        self.parser.synchronizeData(self.items)
        
    }
    

    
    func deleteItemAtIndex(index : Int) {
        if self.items.endIndex >= index {
            if let item = self.items[index] as? AudioItem {
                let fileName = item.title
                self.items.removeAtIndex(index)
                self.deleteAudioRecordFile(fileName)
            }
            
            self.parser.synchronizeData(self.items)
            
        }
    }
    
    // MARK: - Helpers
    
    
    private func deleteAudioRecordFile(fileName : String) {
        var success = false
        
        var error : NSError?
        let fileManager = NSFileManager.defaultManager()
        let audioRecordsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let filePath = audioRecordsPath.stringByAppendingPathComponent(fileName + ".caf")
        
        if fileManager.fileExistsAtPath(filePath) {
            if fileManager.removeItemAtPath(filePath, error: &error) {
                success = true
            } else {
                dbNSLog("Could not delete file -:\(error?.localizedDescription)")
            }
        } else {
            dbNSLog("\(fileName) file doesn't exist in document directory")
        }

        
        self.delegate?.deleteFile(fileName, success: success)
    
    }
    
    
    private func convertItemsToAudioItems() -> [AudioItem] {
        
        var convertedItems : [AudioItem] = []
        for newItem in self.items {
            if let newItem = newItem as? AudioItem {
                convertedItems.append(newItem)
            }
        }
 
        return convertedItems
        
    }

    
    
    
    
}

















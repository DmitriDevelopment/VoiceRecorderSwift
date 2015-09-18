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
    
    private  (set)var items : [AudioItem]
    
    private var parser = ListParser<AudioItem>()
    
    weak var delegate : AudioListDelegate!
    
    private init() {
        items = parser.parseListFromUserDefaults()
    }
    
    // MARK: - Public methods
    
    func isItemExistWithName( name : String ) -> Bool {
        var exist = false
        if !items.filter( { $0.title == name } ).isEmpty {
            exist = true
            return exist
        }
        
        return exist
    }

    
    func addNewItem(newItem : AudioItem, sourceFileURL : NSURL) {

        let newFileURL = sourceFileURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent("\(newItem.title).caf")
        let fileManager = NSFileManager.defaultManager()
        
        var error : NSError?
        if fileManager.fileExistsAtPath(sourceFileURL.path!) {
            do {
                try fileManager.copyItemAtURL(sourceFileURL, toURL: newFileURL)
                self.items.insert(newItem, atIndex: 0)
                self.parser.synchronizeData(self.items)
            } catch let error1 as NSError {
                error = error1
                dbprint("error : \(error?.localizedDescription)")
            }
        }

    }
    

    
    func deleteItemAtIndex(index : Int) {
        if self.items.endIndex >= index {
            let fileName = items[index].title
            self.items.removeAtIndex(index)
            self.deleteAudioRecordFile(fileName)
            
            self.parser.synchronizeData(self.items)
            
        }
    }
    
    // MARK: - Helpers
    
    
    private func deleteAudioRecordFile(fileName : String) {
        var success = false
        
        var error : NSError?
        let fileManager = NSFileManager.defaultManager()
        let audioRecordsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let audioRecordsURL = NSURL(fileURLWithPath: audioRecordsPath)
        let fileURL = audioRecordsURL.URLByAppendingPathComponent(fileName + ".caf")
        
        if fileManager.fileExistsAtPath(fileURL.path!) {
            do {
                try fileManager.removeItemAtPath(fileURL.path!)
                success = true
            } catch let error1 as NSError {
                error = error1
                dbNSLog("Could not delete file -:\(error?.localizedDescription)")
            }
        } else {
            dbNSLog("\(fileName) file doesn't exist in document directory")
        }

        
        self.delegate?.deleteFile(fileName, success: success)
    
    }
    
    
   
    
    
    
    
}

















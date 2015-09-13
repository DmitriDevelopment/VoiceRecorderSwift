//
//  Functions.swift
//  VoiceRecorderSwift
//
//  Created by Дмитрий Буканович on 05.09.15.
//  Copyright (c) 2015 Дмитрий Буканович. All rights reserved.
//

import Foundation


/** custom logging message function
To use this function need to set "-D DEBUG" in
Swift Compiler - Custom Flags -> Other Swift Flags 
in Build Settings
(Working only in debug configuration)*/

func dbprintln<T>(value : T) {
    
    #if DEBUG
        println(value)
        #else
        
    #endif
    
}

/** Extended logging message function
To use this function need to set "-D DEBUG" in
Swift Compiler - Custom Flags -> Other Swift Flags
in Build Settings
(Working only in debug configuration)*/

func dbNSLog(message: String, function: String = __FUNCTION__, file: String = __FILE__) {
    #if DEBUG
        let fileName = NSURL(fileURLWithPath: file)!.lastPathComponent!
        NSLog("file -> %@, function -> %@, message: %@", fileName, function, message)
        #else
        
    #endif
    
}


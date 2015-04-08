//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Douglas Nassaur on 3/17/15.
//  Copyright (c) 2015 Douglas Nassaur. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    
    var filePathUrl: NSURL
    var title: String
    
    init(filePathUrl: NSURL, title: String){
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
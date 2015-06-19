//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Ivan Perelivskiy on 2015.06.17.
//  Copyright (c) 2015 Ivan Perelivskiy. All rights reserved.
//

import Foundation


class RecordedAudio: NSObject {
    var title: String
    var fileURL: NSURL

    init(title: String, fileURL: NSURL) {
        self.title = title
        self.fileURL = fileURL
    }
}

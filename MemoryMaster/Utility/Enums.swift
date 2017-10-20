//
//  Enums.swift
//  MemoryMaster
//
//  Created by apple on 20/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

enum NoteType: String {
    case all = "All"
    case single = "Single"
    case qa = "QuestionAnswer"
}

enum OutletTag: Int {
    case titleTextView = 1
    case bodyTextView = 2
}

enum ReadType: String {
    case edit = "Edit"
    case read = "Read"
    case test = "Test"
}

enum CardStatus: String {
    case titleFront = "titleFront"
    case bodyFrontWithTitle = "bodyFrontWithTitle"
    case bodyFrontWithoutTitle = "bodyFrontWithoutTitle"
}

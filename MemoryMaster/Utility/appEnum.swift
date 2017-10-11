//
//  appEnum.swift
//  MemoryMaster
//
//  Created by apple on 10/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

enum NoteType: String {
    case all = "All"
    case single = "Single"
    case qa = "QuestionAnswer"
}

enum OutletTag: Int {
    case contentTextView = 1
    case titleTextView = 2
    case bodyTextView = 3
    case questionTextView = 4
    case answerTextView = 5
}

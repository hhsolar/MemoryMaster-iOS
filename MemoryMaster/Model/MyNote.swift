//
//  MyNote.swift
//  Recite
//
//  Created by apple on 20/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

struct MyBasicNoteInfo {
    var id: Int
    var time: Date
    var type: String
    var name: String
    var numberOfCard: Int
    
    static func nextNoteID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "noteID")
        userDefaults.set(currentID + 1, forKey: "noteID")
        userDefaults.synchronize()
        return currentID
    }
}

enum NoteType: String {
    case all = "All"
    case single = "Single"
    case qa = "QuestionAnswer"
}

struct SingleCard {
    var title: String
    var body: String
}

struct MySingleNote {
    var name: String
    var cards: [SingleCard]
    var numberOfCard: Int {
        get { return cards.count }
    }
    
    static func formCoreDataType(note: SingleNote) -> MySingleNote {
        var mySingleNote = MySingleNote(name: note.name, cards: [MySingleNote]())
        for i in 0..<note.titles.count {
            let singleCard = SingleCard(title: note.titles[i], body: note.bodies[i])
            mySingleNote.cards.append(singleCard)
        }
        return mySingleNote
    }
    
    func equalTo(_ note: SingleNote) -> Bool {
        guard self.name == note.name else { return false }
        guard self.numberOfCard == Int(note.numberOfCard) else { return false }
        for i in 0..<self.numberOfCard {
            if self.cards[i].title != note.titles[i] || self.cards[i].body != note.bodies[i] {
                return false
            }
        }
        return true
    }
    
    func isEmpty() -> Bool {
        for card in self.cards {
            if card.title != "" || card.body != "" {
                return false
            }
        }
        return true
    }
}

struct QACard {
    var question: String
    var answer: String
}

struct MyQANote {
    var name: String
    var cards: [QACard]
    var numberOfCard: Int {
        get { return cards.count }
    }
    
    static func formCoreDataType(note: QANote) -> MyQANote {
        var myQANote = MyQANote(name: note.name, items: [MyQANote]())
        for i in 0..<note.questions.count {
            let qaCard = QACard(question: note.questions[i], answer: note.answers[i])
            myQANote.cards.append(qaNote)
        }
        return myQANote
    }
    
    func equalTo(_ note: QANote) -> Bool {
        guard self.name == note.name else { return false }
        guard self.numberOfCard == Int(note.numberOfCard) else { return false }
        for i in 0..<self.numberOfCard {
            if self.cards[i].question != note.questions[i] || self.cards[i].answer != note.answers[i] {
                return false
            }
        }
        return true
    }

    func isEmpty() -> Bool {
        for cards in self.cards {
            if card.question != "" || card.answer != "" {
                return false
            }
        }
        return true
    }
}



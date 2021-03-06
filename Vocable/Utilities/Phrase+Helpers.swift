//
//  Phrase+Helpers.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreData

extension Phrase {
    static func create(withUserEntry text: String, in context: NSManagedObjectContext) -> Phrase {
        let newIdentifier = "user_\(UUID().uuidString)"
        let savedCategory = Category.fetchOrCreate(in: context, matching: TextPresets.savedSayingsIdentifier)
        let phrase = Phrase.fetchOrCreate(in: context, matching: newIdentifier)
        phrase.isUserGenerated = true
        phrase.creationDate = Date()
        phrase.lastSpokenDate = Date()
        phrase.utterance = text
        phrase.addToCategories(savedCategory)
        return phrase
    }
}

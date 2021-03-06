//
//  ItemSelection.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine
import CoreData

struct ItemSelection {
    
    @PublishedValue
    static var selectedCategory = Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                      sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
    .compactMap { CategoryViewModel($0) }.first!

    @PublishedValue
    static var selectedPhrase: PhraseViewModel?
    
    @PublishedValue
    static var presetsPageIndicatorProgress: CarouselGridPagingProgress = (pageIndex: 0, pageCount: 0)
}

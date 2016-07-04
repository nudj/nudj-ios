//
//  Array+Sections.swift
//  Nudj
//
//  Created by Richard Buckle on 04/07/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

extension Array {
    typealias SectionSplitPredicate = (Element, Element) -> Bool
    
    func sectionsSplitBy(predicate: SectionSplitPredicate) -> [[Element]] {
        return []
    }
}

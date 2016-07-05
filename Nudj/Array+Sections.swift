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
        var result = [[Element]]()
        
        guard !self.isEmpty else {
            return result
        }
        
        var splitStart = self.startIndex
        let end = self.endIndex.predecessor()
        for index in self.startIndex..<end {
            let isSplit = predicate(self[index], self[index.successor()])
            if isSplit {
                let section = Array(self[splitStart...index])
                result.append(section)
                splitStart = index.successor()
            }
        }
        let lastSection = Array(self[splitStart...end])
        result.append(lastSection)
        
        return result
    }
}

protocol HasInitialCharacter {
    func initialCharacter() -> Character?
}

extension String: HasInitialCharacter {
    func initialCharacter() -> Character? {
        return self.characters.first
    }
}

extension Array where Element: HasInitialCharacter {
    private func splitByInitialLetter(first: HasInitialCharacter, second: HasInitialCharacter) -> Bool {
        let firstInitial = String(first.initialCharacter())
        let secondInitial = String(second.initialCharacter())
        let comparison =  firstInitial.caseInsensitiveCompare(secondInitial)
        return comparison != .OrderedSame
    }
    
    func sectionsByInitialCharacter() -> [[Element]] {
        return sectionsSplitBy(splitByInitialLetter)
    }
}

//
//  FilterModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

struct FilterModel {
    var allContent: [ContactModel]
    var filteredContent: [ContactModel]

    init(content: [ContactModel] = []){
        allContent = content
        filteredContent = content
    }

    init(content: [ContactModel], filteredContent: [ContactModel]){
        allContent = content
        self.filteredContent = filteredContent
    }
    
    func filteredByWordPrefix(wordPrefix: String) -> FilterModel {
        let lowerCaseWordPrefix = wordPrefix.lowercaseString
        
        func filterCriterion(contact: ContactModel) -> Bool {
            // probably quicker than String.enumerateLinguisticTagsInRange(_:scheme:options:orthography:_:) 
            let fullName = contact.name.lowercaseString
            let separators = NSCharacterSet.whitespaceCharacterSet()
            let words = fullName.componentsSeparatedByCharactersInSet(separators)
            for word in words {
                if word.hasPrefix(lowerCaseWordPrefix) {
                    return true
                }
            }
            return false 
        }
        
        let filteredContent = allContent.filter(filterCriterion)
        return FilterModel(content: allContent, filteredContent: filteredContent)
    }
    
    func unfiltered() -> FilterModel {
        return FilterModel(content: allContent)
    }
    
    /// Complexity O(n)
    func contactWithID(contactID: Int) -> ContactModel? {
        let index = allContent.indexOf{ $0.id == contactID }
        if let index = index {
            return allContent[index]
        }
        return nil
    }
    
    func filteredRowWithIdentifier(identifier: String) -> Int? {
        return filteredContent.indexOf{ $0.apple_id == identifier }
    }
    
    func unfilteredRowWithIdentifier(identifier: String) -> Int? {
        return allContent.indexOf{ $0.apple_id == identifier }
    }
}

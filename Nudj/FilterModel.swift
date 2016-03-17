//
//  FilterModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

struct FilterModel {
    var allContent = [ContactModel]()
    var filteredContent = [ContactModel]()

    init(content: [ContactModel] = []){
        setContent(content)
    }
    
    mutating func setContent(content: [ContactModel]) {
        allContent = content
        filteredContent = content
    }

    mutating func startFiltering(filteringText:String, completionHandler: (success: Bool) -> Void) {
        let lowerCaseFilter = filteringText.lowercaseString
        filteredContent = allContent.filter{ $0.name.lowercaseString.hasPrefix(lowerCaseFilter) }
        completionHandler(success: true)
    }
    
    mutating func stopFiltering() {
        filteredContent = allContent
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

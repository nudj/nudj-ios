//
//  FilterModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class FilterModel: NSObject {

    var allContent = [ContactModel]()
    var filteredContent = [ContactModel]()

    override init() {
    }

    init(content:[ContactModel]){
        self.allContent = content
        self.filteredContent = content
    }

    func startFiltering(filteringText:String, completionHandler:(success:Bool) -> Void) {
        let lowerCaseFilter = filteringText.lowercaseString
        self.filteredContent = self.allContent.filter({ 
            element in
            element.name.lowercaseString.hasPrefix(lowerCaseFilter)
        })
        completionHandler(success:true)
    }
    
    func stopFiltering(){
        self.filteredContent = self.allContent
    }

    func setContent(content:[ContactModel]) {
        self.allContent = content
        self.filteredContent = content
    }
    
    /// Complexity O(n)
    func contactWithID(contactID: Int) -> ContactModel? {
        let index = allContent.indexOf{$0.id == contactID}
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

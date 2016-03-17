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
    
    func filteredRowWithIdentifier(identifier: String) -> Int? {
        return filteredContent.indexOf{ $0.apple_id == identifier }
    }
}

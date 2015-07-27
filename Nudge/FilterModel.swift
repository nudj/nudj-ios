//
//  FilterModel.swift
//  Nudge
//
//  Created by Antonio on 23/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class FilterModel: NSObject {

    var allContent:[ContactModel] = []
    var filteredContent:[ContactModel] = []
    
    init(content:[ContactModel]){
        
        self.allContent = content
        self.filteredContent = content
        
    }
    
    
    func startFiltering(filteringText:String, completionHandler:(success:Bool) -> Void) {
        
        println("filtering -> \(filteringText)")
        
        self.filteredContent = self.allContent.filter({ text in
            
            text.name.lowercaseString.hasPrefix(filteringText.lowercaseString)
            
        })
        
        
        /*if(self.filteredContent.count == 0){
            
            self.filteredContent = self.allContent
        
        }*/
        
        completionHandler(success:true)
    }
    
    func stopFiltering(){
        
        self.filteredContent = self.allContent
        
    }
    
}

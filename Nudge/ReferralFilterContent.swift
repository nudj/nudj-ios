//
//  ReferralFilterContent.swift
//  Nudge
//
//  Created by Antonio on 30/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class ReferralFilterContent: NSObject {
 
    
    var name: NSString?;
    var type: NSString?;
    var desc: NSString?;
    var glossaryIndex :NSArray?;
    var contactsGlosarry :NSMutableArray?;
    
    override init(){
        
        super.init()
        
    }
    
    func glossaryContent(){
        
        self.contactsGlosarry = NSMutableArray();
        
    }
    
    func productWithType(type:NSString, names name:NSString,  description desc:NSString) -> ReferralFilterContent{
    
        var newProduct: ReferralFilterContent =  self
        
        newProduct.type = type;
        newProduct.name = name;
        newProduct.desc = desc;
        
        return newProduct;
    }
    

    
}

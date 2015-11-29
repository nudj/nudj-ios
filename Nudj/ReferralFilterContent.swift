//
//  ReferralFilterContent.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class ReferralFilterContent: NSObject {
 
    
    var name: String?;
    var glossaryIndex :NSArray?;
    var contactsGlosarry :NSMutableArray?;
    
    override init(){
        
        super.init()
        self.contactsGlosarry = NSMutableArray();
    }
    
    
    func productWithType(name:String) -> ReferralFilterContent{
    
        var newProduct: ReferralFilterContent =  self
        newProduct.name = name;
        return newProduct;
        
    }
    

    
}

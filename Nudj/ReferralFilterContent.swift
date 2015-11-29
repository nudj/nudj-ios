//
//  ReferralFilterContent.swift
//  Nudj
//
//  Created by Antonio on 30/06/2015.
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

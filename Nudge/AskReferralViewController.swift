//
//  AskReferralViewController.swift
//  Nudge
//
//  Created by Antonio on 30/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class AskReferralViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet var messageText: UITextField!
    @IBOutlet var searchBar: UISearchBar!
    var currentContent :NSMutableArray?;
    var indexes:NSArray?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.frame = CGRectMake(0, 0, messageText.frame.size.width, messageText.frame.size.height);
        // Do any additional setup after loading the view.
        
        currentContent = NSMutableArray();
        indexes = NSArray();
        
        var content :ReferralFilterContent = ReferralFilterContent()
        content.glossaryContent()
        content.glossaryIndex = ["Andy","Becky","Caroline","David"];
        
        
        for var i = 0; i < content.glossaryIndex?.count; i++ {
            
            //content.glossaryContent.addObject( content.productWithType(content.glossaryIndex[i]) );
            
        }
        
         indexes = content.glossaryIndex?.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

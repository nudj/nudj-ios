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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.frame = CGRectMake(0, 0, messageText.frame.size.width, messageText.frame.size.height);
        // Do any additional setup after loading the view.
        
        currentContent = NSMutableArray();
        
        var content :ReferralFilterContent = ReferralFilterContent()
        content.glossaryContent()
        content.glossaryIndex = ["Andy","Becky","Caroline","David"];
        
        
        for var i = 0; i < content.glossaryIndex?.count; i++ {
            //content.glossaryContent.addObject( content.productWithType("", names: content.glossaryIndex[i], description:"") );
        }
        
        // indexes = [[allVals allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

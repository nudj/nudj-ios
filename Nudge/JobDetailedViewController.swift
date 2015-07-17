//
//  JobDetailedViewController.swift
//  Nudge
//
//  Created by Antonio on 29/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class JobDetailedViewController: BaseController {
    @IBOutlet var jobTitleText: UILabel!
    @IBOutlet var authorName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var employerText: NZLabel!
    @IBOutlet var locationText: NZLabel!
    @IBOutlet var salaryText: NZLabel!
    @IBOutlet var bonusText: NZLabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test property
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 22)
        
        bonusText.setFont(boldFont, string: "£900")
        bonusText.setFontColor(UIColor.blueColor(), string: "£900")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBarHidden = false;
        
        self.requestData()

    }
    
    func requestData(){
        
        /*self.apiRequest(Alamofire.Method.GET, path:"jobs/7", closure: { json in
            
            println("Data -> " + json["data"])
            
        })*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Nudge(sender: UIButton) {
    }

    @IBAction func interested(sender: UIButton) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

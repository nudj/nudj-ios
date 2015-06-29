//
//  AddJobController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 30.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

@IBDesignable
class AddJobController: UIViewController,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var jobTableView: UITableView!

    let cellIdentifier = "AddJobCell"

    let structure: [AddJobItem] = [
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Job Title"),
        AddJobItem(type: AddJobbCellType.BigText, image: "second", placeholder: "Job Description (keep it brief)"),
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Add Skills Tags"),
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Salary Details"),
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Employer"),
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Tag Location"),
        AddJobItem(type: AddJobbCellType.Field, image: "second", placeholder: "Job Status")
    ];
    
    override func viewDidLoad() {
        
        self.jobTableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.jobTableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    @IBAction func backAction(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func PostAction(sender: AnyObject) {
        
       //jobs POST jobs/1
        
    }

    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.structure.count
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row != 1){
            return 52;
        }else{
            return 100;
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddJobCell
        let data = structure[indexPath.row]

        cell.setup(data.type, image: data.image, placeholder: data.placeholder)

        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
}

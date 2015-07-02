//
//  AddJobController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 30.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

@IBDesignable
class AddJobController: UIViewController,UITableViewDataSource,UITableViewDelegate, CreatePopupViewDelegate{

    @IBOutlet var jobTableView: UITableView!
    var popup :CreatePopupView?;
    
    let cellIdentifier = "AddJobCell"

    let structure: [AddJobItem] = [
        AddJobItem(type: AddJobbCellType.Field, image: "job_title_active", placeholder: "Job Title"),
        AddJobItem(type: AddJobbCellType.BigText, image: "job_description_active", placeholder: "Job Description (keep it brief)"),
        AddJobItem(type: AddJobbCellType.Field, image: "add_skills_active", placeholder: "Add Skills Tags"),
        AddJobItem(type: AddJobbCellType.Field, image: "salary_details_active", placeholder: "Salary Details"),
        AddJobItem(type: AddJobbCellType.Field, image: "employer_active", placeholder: "Employer"),
        AddJobItem(type: AddJobbCellType.Field, image: "tag_location_active", placeholder: "Tag Location"),
        AddJobItem(type: AddJobbCellType.Field, image: "job_title_active", placeholder: "Job Status"),
        AddJobItem(type: AddJobbCellType.empty, image: "", placeholder: "")
    ];
    
    override func viewDidLoad() {
        
        self.navigationController?.tabBarController?.hidesBottomBarWhenPushed = true;
        self.jobTableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.jobTableView.tableFooterView = UIView(frame: CGRectZero)
        
        //-------------------------------New resizing text
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);

    }
    
    
    @IBAction func backAction(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func PostAction(sender: AnyObject) {
        
       //jobs POST jobs/1
       //['id', 'title', 'description', 'salary', 'status', 'bonus']
        //self.createPopup()
        
        popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"this_job_has-been_posted", withText: false);
        popup?.delegate = self;
        
        self.view.addSubview(popup!)
        
    }

    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.structure.count;
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row != 1 && indexPath.row != 7){
            return 52;
        }else if(indexPath.row  == 7){
            return 90;
        }else{
            return 100;
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddJobCell
        let data = structure[indexPath.row];

        cell.setup(data.type, image: data.image, placeholder: data.placeholder);
        
        if(indexPath.row == 7){
            
            var setReferalLabel : UILabel = UILabel(frame: CGRectMake(0, 30, self.view.frame.width, 30));
            setReferalLabel.text = "Set Referal Bonus";
            setReferalLabel.numberOfLines = 0;
            setReferalLabel.textAlignment = NSTextAlignment.Center;
            setReferalLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24);
            cell.addSubview(setReferalLabel);
            
        }
        
        return cell;
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    //---------------------------------------------------------------------------------
    //--------------------------- COMMENTS KEYBOARD METHODS
    
    // MARK: -- COMMENTS KEYBOARD METHODS
    func keyboardWillShow(note: NSNotification){
    
    /*println("keyboard open");
    
    // get keyboard size and loctaion
    var keyboardBounds :CGRect?
        
    note.userInfo.valueForKeyUIKeyboardFrameEndUserInfoKey
        
        
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    
    
    [_commentsTable setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-keyboardBounds.size.height-40-64)];
    
    [self.view bringSubviewToFront:containerView];
    
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.commentJson count]-1 inSection:0];
    
    if([self.commentJson count] >0)
    [_commentsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    */
    }
    
    func keyboardWillHide(note: NSNotification){
    
    /*
    NSLog(@"keyboard closed.");
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    [_commentsTable setFrame:CGRectMake(0, 64, 320, shareIstance.deviceHeight-40-64)];
    
    if([self.commentJson count]!=0)
    [_commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentJson count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    */
        
    }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        
        //Go to ask view
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var askController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("AskReferralView") as! UIViewController
        self.navigationController?.pushViewController(askController, animated: true)
        
    }
}

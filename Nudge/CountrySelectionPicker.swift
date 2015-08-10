//
//  CountrySelectionPicker.swift
//  Nudge
//
//  Created by Antonio on 10/08/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
protocol CountrySelectionPickerDelegate {
    
    func didSelect(selection:[String:String])

}

class CountrySelectionPicker: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate : CountrySelectionPickerDelegate?
    var selection = ["dial_code":"+44","name":"United Kingdom","code":"GB"]
    var data = []
    var isCreated:Bool = false;
    
    func createDropActionSheet(view:UIView) -> UIView{
        
        self.backgroundColor = UIColor.whiteColor()
        self.frame = CGRectMake(0, view.frame.size.height - 220, view.frame.size.width, 220)
        
        var topline = UIView(frame: CGRectMake(0, 0, self.frame.size.width , 1))
        topline.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(topline)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var title = UILabel(frame: CGRectMake(0, 5, self.frame.size.width, 30))
        title.text = "Choose your country"
        title.textAlignment = NSTextAlignment.Center
        title.textColor = appDelegate.appColor
        self.addSubview(title)
        
        var button = UIButton(frame: CGRectMake(self.frame.size.width - 70, 5, 60, 30))
        button.setTitle("Done", forState: UIControlState.Normal)
        button.setTitleColor(appDelegate.appColor, forState: UIControlState.Normal)
        button.addTarget(self, action: "doneAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        var picker = UIPickerView(frame: CGRectMake(0, 25, self.frame.size.width, 216))
        picker.delegate = self
        picker.dataSource = self
        self.addSubview(picker)
        
        var bottomline = UIView(frame: CGRectMake(0, 35, self.frame.size.width , 1))
        bottomline.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(bottomline)
        
        self.hidden = true
        self.isCreated = true
        
        var dataSource = CountryListDataSource()
        data = dataSource.countries()
        
        
        return self
    
    }
    //MARK: - Delegates and datasources
    
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
 
        selection = data[row] as! [String:String]
        
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return data.count
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        if let code = data[row].valueForKey("dial_code") as? String {

            var text = data[row].valueForKey("name") as! String
            return "\(text) (\(code))"
        
        }
        
            return data[row].valueForKey("name") as! String

    }
    
    func showAction(){
        
        self.hidden = false
        
        //TODO: Animate
        
    }
    
    func doneAction(){
        //TODO: Animate
        
        self.hidden = true
        delegate?.didSelect(selection)
        
    }
    

}

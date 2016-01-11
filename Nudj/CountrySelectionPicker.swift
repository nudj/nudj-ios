//
//  CountrySelectionPicker.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol CountrySelectionPickerDelegate {
    func didSelect(selection:[String:String])
}

class CountrySelectionPicker: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    // TODO: API strings
    var delegate : CountrySelectionPickerDelegate?
    var selection = ["dial_code": Localizations.Country.Default.Dialcode,
        "name": Localizations.Country.Default.Name,
        "code": Localizations.Country.Default.Code]
    var picker:UIPickerView?
    var data:[AnyObject] = []
    var isCreated:Bool = false;
    
    func createDropActionSheet(y:CGFloat,width:CGFloat) -> UIView{
        
        self.backgroundColor = UIColor.whiteColor()
        self.frame = CGRectMake(0,y,width,220)
        
        let topline = UIView(frame: CGRectMake(0, 0, self.frame.size.width , 1))
        topline.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(topline)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let title = UILabel(frame: CGRectMake(0, 5, self.frame.size.width, 30))
        title.text = Localizations.Country.Choose.Label
        title.textAlignment = NSTextAlignment.Center
        title.textColor = appDelegate.appColor
        self.addSubview(title)
        
        let button = UIButton(frame: CGRectMake(self.frame.size.width - 70, 5, 60, 30))
        button.setTitle(Localizations.General.Button.Done, forState: UIControlState.Normal)
        button.setTitleColor(appDelegate.appColor, forState: UIControlState.Normal)
        button.addTarget(self, action: "doneAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        picker = UIPickerView(frame: CGRectMake(0, 25, self.frame.size.width, 216))
        picker!.delegate = self
        picker!.dataSource = self
        self.addSubview(picker!)
        
        let bottomline = UIView(frame: CGRectMake(0, 35, self.frame.size.width , 1))
        bottomline.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(bottomline)
        
        self.hidden = true
        self.isCreated = true
        
        self.requestCountries()
        
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // TODO: API strings
        let text = data[row].valueForKey("name") as! String
        let code = data[row].valueForKey("dial_code") as! String
        return "\(text) (\(code))"
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
    
    func requestCountries() {
        // TODO: API strings
        // TODO: should be a method on the API class
        let api = API()
        Alamofire.request(API.Method.GET, api.server.URLString + "countries").responseJSON{
            response in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                for (_, obj) in json {
                    let dial_code = "+" + obj["code"].stringValue
                    let name = obj["name"].stringValue
                    let code = obj["iso2"].stringValue
                    self.data.append(["dial_code":dial_code, "name":name, "code":code])
                }
                
                self.picker!.reloadAllComponents()
                break
                
            case .Failure:
                // TODO: handle failure
                break
            }
        }
    }
}

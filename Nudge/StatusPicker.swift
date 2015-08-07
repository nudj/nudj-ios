//
//  StatusPicker.swift
//  Nudge
//
//  Created by Lachezar Todorov on 10.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class StatusPicker: BaseController, UIPickerViewDelegate, UIPickerViewDataSource {

    var availableStatuses = [Int: String]()
    var selectedStatus = 0
    
    @IBOutlet weak var picker: UIPickerView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        API.sharedInstance.get("config/status", params: nil, closure: {
            json in
            for (key, value) in json["data"] {
                self.availableStatuses.updateValue(value.stringValue, forKey: key.toInt()!)
            }
            self.picker.reloadAllComponents()
        })
    }

    @IBAction func done(sender: UIBarButtonItem) {
        println(["status": self.selectedStatus])
        self.apiUpdateUser(["status": self.selectedStatus], closure: { _ in
            self.hide()
        })
    }

    func hide() {
        self.navigationController!.popViewControllerAnimated(true)
    }

    //MARK: - Delegates and datasources

    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.availableStatuses.count
    }

    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.availableStatuses[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedStatus = row
    }
}

//
//  StatusPicker.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class StatusPicker: BaseController, UIPickerViewDelegate, UIPickerViewDataSource {

    var availableStatuses = [Int: String]()
    var selectedStatus = 0
    
    @IBOutlet weak var picker: UIPickerView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // TODO: remove this abuse of the NSCoder protocol
        let path = API.Endpoints.Config.status
        API.sharedInstance.request(.GET, path: path, params: nil, closure: {
            json in
            for (key, value) in json["data"] {
                if let key = Int(key) {
                    self.availableStatuses[key] = value.stringValue
                }
            }
            self.picker.reloadAllComponents()
        })
    }

    @IBAction func done(sender: UIBarButtonItem) {
        let path = API.Endpoints.Users.base
        let params = ["status": self.selectedStatus]
        self.apiRequest(.PUT, path: path, params: params)
        self.hide()
    }

    func hide() {
        self.navigationController?.popViewControllerAnimated(true)
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
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row > availableStatuses.count ? "" : availableStatuses[row+1]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedStatus = row
    }
}

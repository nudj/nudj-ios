//
//  CountryPickerDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 22/01/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class CountryPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    struct Data {
        let country: String
        let diallingCode: String
        let iso2Code: String
    }
    
    let data: [Data]
    
    override convenience init() {
        if let url = NSBundle.mainBundle().URLForResource("Dialling Codes", withExtension: "plist"),
            root = NSDictionary(contentsOfURL: url),
        countries = root["countries"] as? [[String:String]] {
            let data: [Data] = countries.map{Data(country: $0["country"]!, diallingCode: $0["dialling code"]!, iso2Code: $0["iso2"]!)}
            self.init(data: data)
        } else {
            self.init(data: [])
        }
    }
    
    init(data: [Data]) {
        self.data = data
        super.init()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
}

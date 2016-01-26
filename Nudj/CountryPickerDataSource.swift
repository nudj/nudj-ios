//
//  CountryPickerDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 22/01/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

@objc protocol CountryPickerDelegate: class {
    func didSelectData(data: CountryPickerDataSource.Data)
}

class CountryPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    // Ideally Data would be a struct, but that prevents protocol CountryPickerDelegate
    // from being expressible in Obj-C, which prevents the delegate from being an IBOutlet.
    // This is a compromise solution biased towards wiring the delagate in IB rather than in code.
    // Not as Swifty as I'd like, but no worse than a standard Obj-C implementation would be.
    class Data: NSObject { 
        let country: String
        let diallingCode: String
        let iso2CountryCode: String
        let shouldStripLeadingZeros: Bool
        
        convenience init(fromDictionary dictionary:[String:AnyObject]) {
            self.init(
                country: dictionary["country"]! as! String, 
                diallingCode: dictionary["diallingCode"]! as! String, 
                iso2CountryCode: dictionary["iso2CountryCode"]! as! String,
                shouldStripLeadingZeros: dictionary["shouldStripLeadingZeros"] as? Bool ?? false
            )
        }
        
        init(country: String = "", diallingCode: String = "", iso2CountryCode: String = "", shouldStripLeadingZeros: Bool = false) {
            self.country = country
            self.diallingCode = diallingCode
            self.iso2CountryCode = iso2CountryCode
            self.shouldStripLeadingZeros = shouldStripLeadingZeros
            super.init()
        }
    }
    
    let data: [Data]
    @IBOutlet weak var delegate: CountryPickerDelegate?
    
    override convenience init() {
        // init from static data "Dialling Codes.plist" in the main bundle
        if let url = NSBundle.mainBundle().URLForResource("Dialling Codes", withExtension: "plist"),
            root = NSDictionary(contentsOfURL: url),
            countries = root["countries"] as? [[String:AnyObject]] {
                let data: [Data] = countries.map{Data(fromDictionary: $0)}
            self.init(data: data)
        } else {
            loggingPrint("error reading Dialling Codes.plist")
            self.init(data: [])
        }
    }
    
    init(data: [Data]) {
        self.data = data
        super.init()
    }
    
    func rowForIso2CountryCode(iso2CountryCode: String) -> (Int, Data)? {
        let row = data.indexOf{$0.iso2CountryCode == iso2CountryCode}
        if let row = row {
            let rowData = data[row]
            return (row, rowData)
        } else {
            return nil
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard component == 0 else {return nil}
        let rowData = data[row]
        return "\(rowData.country) (+\(rowData.diallingCode))"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component == 0 else {return}
        let rowData = data[row]
        delegate?.didSelectData(rowData)
    }
}
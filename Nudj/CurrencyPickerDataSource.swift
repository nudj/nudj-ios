//
//  CurrencyPickerDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 28/06/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

@objc protocol CurrencyPickerDelegate: class {
    func didSelectCurrency(isoCode: String, symbol: String)
}

class CurrencyPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    struct Data {
        let name: String
        let isoCode: String
    }
    
    @IBOutlet weak var delegate: CurrencyPickerDelegate?
    let nativeCurrency: String
    private let locale: NSLocale
    private let currencyFormatter: NSNumberFormatter
    private let data: [Data]
    
    override init() {
        let locale = NSLocale.autoupdatingCurrentLocale()
        self.locale = locale
        
        let nativeCurrency = locale.objectForKey(NSLocaleCurrencyCode) as? String ?? "USD"
        self.nativeCurrency = nativeCurrency
        
        currencyFormatter = NSNumberFormatter()
        currencyFormatter.locale = locale
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.maximumFractionDigits = 0
        
        let codes = NSLocale.commonISOCurrencyCodes()
        data = codes.map {
            code -> Data in
            let name = locale.displayNameForKey(NSLocaleCurrencyCode, value: code)
            return Data(name: name ?? code, isoCode: code)
        }.sort { $0.name < $1.name }
        
        super.init()
    }
    
    func symbolForCurrency(isoCode: String) -> String {
        return locale.displayNameForKey(NSLocaleCurrencySymbol, value: isoCode) ?? isoCode
    }
    
    func rowForCurrency(isoCode: String) -> Int? {
        return data.indexOf { $0.isoCode == isoCode }
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
        return rowData.name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component == 0 else {return}
        let rowData = data[row]
        let isoCode = rowData.isoCode
        let symbol = symbolForCurrency(isoCode)
        delegate?.didSelectCurrency(isoCode, symbol: symbol)
    }
}

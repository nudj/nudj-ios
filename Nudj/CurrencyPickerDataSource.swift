//
//  CurrencyPickerDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 28/06/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class CurrencyPickerDataSource: NSObject, UITableViewDataSource {
    struct Data: HasInitialCharacter {
        let name: String
        let isoCode: String

        func initialCharacter() -> Character? {
            return name.initialCharacter()
        }
    }
    
    let nativeCurrency: String
    private let locale: NSLocale
    private let currencyFormatter: NSNumberFormatter
    private let allData: [Data]
    private let sectionedData: [[Data]]
    private let cellIdentifier = "CurrencyCell"
    
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
        allData = codes.map {
            code -> Data in
            let name = locale.displayNameForKey(NSLocaleCurrencyCode, value: code)
            return Data(name: name ?? code, isoCode: code)
        }.sort { $0.name < $1.name }
        
        sectionedData = allData.sectionsByInitialCharacter()
        
        super.init()
    }
    
    func symbolForCurrency(isoCode: String) -> String {
        return locale.displayNameForKey(NSLocaleCurrencySymbol, value: isoCode) ?? isoCode
    }
    
    func dataForIndexPath(indexPath: NSIndexPath) -> Data? {
        let section = indexPath.section
        guard section < sectionedData.count else {
            return nil
        }
        let sectionArray = sectionedData[section]
        let row = indexPath.row
        guard row < sectionArray.count else {
            return nil
        }
        return sectionArray[row]
    }
    
    func indexPathForCurrencyCode(isoCode: String) -> NSIndexPath? {
        var section: Int? = nil
        var row: Int? = nil
        section = sectionedData.indexOf{
            array in
            row = array.indexOf{
                data in
                return data.isoCode == isoCode
            }
            return row != nil
        }
        guard let foundSection = section, foundRow = row else {
            return nil
        }
        return NSIndexPath(forRow: foundRow, inSection: foundSection)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedData.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sectionedData[section].first?.initialCharacter())
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionedData.map{String($0.first?.initialCharacter)}
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedData[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let data = dataForIndexPath(indexPath)
        cell.textLabel?.text = data?.name
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

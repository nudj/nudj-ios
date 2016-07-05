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
    
    @IBOutlet weak var currencyTable: UITableView!
    var searchController: UISearchController!
    
    let nativeCurrency: String
    private let locale: NSLocale
    private let currencyFormatter: NSNumberFormatter
    private let allData: [Data]
    private var filteredData: [Data]
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
        func codeToData(code: String) -> Data {
            let name = locale.displayNameForKey(NSLocaleCurrencyCode, value: code)
            return Data(name: name ?? code, isoCode: code)
        }
        allData = codes.map(codeToData).sort { $0.name < $1.name }
        
        sectionedData = allData.sectionsByInitialCharacter()
        filteredData = allData

        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false

        super.init()
        searchController.searchResultsUpdater = self
    }
    
    func symbolForCurrency(isoCode: String) -> String {
        return locale.displayNameForKey(NSLocaleCurrencySymbol, value: isoCode) ?? isoCode
    }
    
    func isSearching() -> Bool {
        return searchController.active && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    func dataForIndexPath(indexPath: NSIndexPath) -> Data? {
        if isSearching() {
            let row = indexPath.row
            guard row < filteredData.count else {
                return nil
            }
            return filteredData[indexPath.row]
        }
        
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
    
    func indexPathForCurrencyCode(isoCode: String?) -> NSIndexPath? {
        guard let isoCode = isoCode else {
            return nil
        }
        
        if isSearching() {
            guard let row = filteredData.indexOf({ $0.isoCode == isoCode }) else {
                return nil
            }
            return NSIndexPath(forRow: row, inSection: 0)
        }
        
        var section: Int? = nil
        var row: Int? = nil
        section = sectionedData.indexOf{
            array in
            row = array.indexOf{ $0.isoCode == isoCode }
            return row != nil
        }
        guard let foundSection = section, foundRow = row else {
            return nil
        }
        return NSIndexPath(forRow: foundRow, inSection: foundSection)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSearching() {
            return 1
        }
        return sectionedData.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching() {
            return nil
        }
        return String(sectionedData[section].first!.initialCharacter()!)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if isSearching() {
            return nil
        }
        return sectionedData.map{String($0.first!.initialCharacter()!)}
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching() {
            return filteredData.count
        }
        return sectionedData[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let data = dataForIndexPath(indexPath)
        cell.textLabel?.text = data?.name
        let selectedIndexPath = tableView.indexPathForSelectedRow
        let selected = (selectedIndexPath?.compare(indexPath) ?? .OrderedAscending) == .OrderedSame
        cell.accessoryType = selected ? .Checkmark : .None
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

extension CurrencyPickerDataSource: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchString = searchController.searchBar.text?.lowercaseString {
            filteredData = allData.filter{ $0.name.lowercaseString.containsString(searchString) }
        } else {
            filteredData = allData
        }
        currencyTable.reloadData()
    }
}

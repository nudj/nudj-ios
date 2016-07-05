//
//  CurrencyPickerViewController.swift
//  Nudj
//
//  Created by Richard Buckle on 05/07/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

protocol CurrencyPickerDelegate: class {
    func didSelectCurrency(isoCode: String, symbol: String)
}

class CurrencyPickerViewController: UIViewController {
    @IBOutlet weak var currencyTable: UITableView!
    @IBOutlet var dataSource: CurrencyPickerDataSource!
    
    weak var delegate: CurrencyPickerDelegate?
    
    var selectedCurrencyIsoCode: String? {
        get {
            guard let indexPath = currencyTable.indexPathForSelectedRow else {
                return nil
            }
            let data = dataSource.dataForIndexPath(indexPath)
            return data?.isoCode
        }
        set {
            let isoCode = newValue ?? dataSource.nativeCurrency
            if let indexPath = dataSource.indexPathForCurrencyCode(isoCode) {
                currencyTable.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                if let indexPath = currencyTable.indexPathForSelectedRow {
                    currencyTable.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }
    }
    
    func symbolForCurrencyCode(isoCode: String) -> String {
        return dataSource.symbolForCurrency(isoCode)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        if let isoCode = selectedCurrencyIsoCode {
            let symbol = symbolForCurrencyCode(isoCode)
            delegate?.didSelectCurrency(isoCode, symbol: symbol)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}

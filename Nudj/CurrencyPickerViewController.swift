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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyTable.delegate = self
    }
    
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
                currencyTable.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Middle)
                tableView(currencyTable, didSelectRowAtIndexPath: indexPath)
            } else {
                if let indexPath = currencyTable.indexPathForSelectedRow {
                    currencyTable.deselectRowAtIndexPath(indexPath, animated: true)
                    tableView(currencyTable, didDeselectRowAtIndexPath: indexPath)
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

extension CurrencyPickerViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.groupTableViewBackgroundColor()
    }
}

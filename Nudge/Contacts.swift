//
//  AddressBook.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import AddressBook
import UIKit

class Contacts {

    var book : ABAddressBook!

    init() {
        
    }

    static var images = [String: UIImage]()

    func createAddressBook() -> Bool {
        if self.book != nil {
            return true
        }

        var err : Unmanaged<CFError>? = nil
        let book : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if book == nil {
            println(err)
            self.book = nil
            return false
        }

        self.book = book
        return true
    }

    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()

        switch status {
            case .Authorized:
                return self.createAddressBook()

            case .NotDetermined:
                var ok = false
                ABAddressBookRequestAccessWithCompletion(nil) {
                    (granted:Bool, err:CFError!) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if granted {
                            ok = self.createAddressBook()
                        }
                    }
                }
                if ok == true {
                    return true
                }

                self.book = nil
                return false

            case .Restricted:
                self.book = nil
                return false

            case .Denied:
                self.book = nil
                return false
        }
    }

    func isAuthorized() -> Bool {
        return ABAddressBookGetAuthorizationStatus() == .Authorized
    }

    func getContactNames() {
        if !self.determineStatus() {
            println("not authorized")
            return
        }
        let people = ABAddressBookCopyArrayOfAllPeople(self.book).takeRetainedValue() as NSArray as [ABRecord]



        for person in people {
            let birthday = ABRecordCopyValue(person, kABPersonBirthdayProperty);
            let nameRef = ABRecordCopyCompositeName(person)

            if (nameRef == nil || birthday == nil) {
                continue
            }

            let name = nameRef.takeRetainedValue()
//            let socialProfiles: ABMultiValueRef = ABRecordCopyValue(person, kABPersonInstantMessageProperty).takeRetainedValue() as ABMultiValueRef
            let socialProfiles: ABMultiValueRef = ABRecordCopyValue(person, kABPersonSocialProfileProperty).takeRetainedValue() as ABMultiValueRef

            println("Social Profiles")
            println(ABMultiValueGetCount(socialProfiles))

            for var index:CFIndex = 0; index < ABMultiValueGetCount(socialProfiles); ++index {

                if let socialProfile: AnyObject = ABMultiValueCopyValueAtIndex(socialProfiles, index).takeRetainedValue() as? NSDictionary {

//                    if (socialProfile["service"] as String == "Facebook") {
                        println(socialProfile)
//                    }

                }
            }

            if (birthday == nil) {
                println(name, "No Birthday!")
            } else {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                let date = birthday.takeRetainedValue() as! NSDate
                println(name, formatter.stringFromDate(date))
            }
        }
    }

    func sync() {
        if (!self.isAuthorized()) {
            println("not authorized")
            return
        }

        if (self.book == nil) {
            self.createAddressBook()
        }

        var contacts = [String: String]()
        let people = ABAddressBookCopyArrayOfAllPeople(self.book).takeRetainedValue() as NSArray as [ABRecord]
        for person in people {
            let numbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
            if (ABMultiValueGetCount(numbers) > 0) {

                if let name = ABRecordCopyCompositeName(person) {
                    if let phone = ABMultiValueCopyValueAtIndex(numbers, 0) {
                        contacts.updateValue(name.takeRetainedValue() as String, forKey: phone.takeRetainedValue() as! String)
                    }
                }
                

            }
        }

        if (contacts.isEmpty) {
            return
        }

        println(contacts)

        BaseController().apiRequest(.PUT, path: "users", params: ["contacts": contacts], closure: {result in println(result)}, errorHandler: {result in println(result)})
    }
}
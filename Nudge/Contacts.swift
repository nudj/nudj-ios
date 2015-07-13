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

    var cache = [Int:UIImage]()

    func createAddressBook(force:Bool = false) -> Bool {

        if (!force && self.book != nil) {
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

    func createProjectContact() {
        if (!self.isAuthorized()) {
            return
        }

        if (self.book == nil) {
            self.createAddressBook()
        }

        var newContact:ABRecordRef! = ABPersonCreate().takeRetainedValue()

        var error: Unmanaged<CFErrorRef>? = nil

        ABRecordSetValue(newContact, kABPersonFirstNameProperty, "Nudj", &error)

//        ABRecordSetValue(newContact, kABPersonPhoneMainLabel, "+442033223966", &error)

        ABAddressBookAddRecord(self.book, newContact, &error)
        ABAddressBookSave(self.book, &error)
    }

    func getContactImageDataForId(contactId:Int) -> UIImage?  {

        if let cachedImage = self.cache[contactId] {
            println("Taken from cache")
            return cachedImage
        } else {
            print("Searching for: \(contactId)")
        }

        if (!self.isAuthorized()) {
            return nil
        }

        if (self.book == nil) {
            self.createAddressBook()
        }

        let recordId = ABRecordID(contactId)

        let userRef = ABAddressBookGetPersonWithRecordID(self.book, recordId)

        if (userRef == nil) {
            return nil
        }

        let user: ABRecord = userRef.takeRetainedValue()

        if (ABPersonHasImageData(user)) {
            if let imageRef = ABPersonCopyImageDataWithFormat(user, kABPersonImageFormatThumbnail) {
                self.cache[contactId] = UIImage(data: imageRef.takeRetainedValue())
                return self.cache[contactId]
            }
        } else {
            let linkedRef = ABPersonCopyArrayOfAllLinkedPeople(user)

            if (linkedRef == nil) {
                return nil
            }

            let linked = linkedRef.takeRetainedValue() as NSArray as [ABRecord]

            if (linked.count <= 0) {
                return nil
            }

            for linkedUser: ABRecordRef in linked {
                if (ABPersonHasImageData(linkedUser)) {
                    if let imageRef = ABPersonCopyImageDataWithFormat(linkedUser, kABPersonImageFormatThumbnail) {
                        self.cache[contactId] = UIImage(data: imageRef.takeRetainedValue())
                        return self.cache[contactId]

                    }
                }
            }
        }

        return nil
    }

    func sync(closure:((Bool)->())? = nil) {
        if (!self.isAuthorized()) {
            println("not authorized")
            determineStatus()
            return
        }

        if (self.book == nil) {
            self.createAddressBook()
        }

        var contacts = [[String:String]]()

        let people = ABAddressBookCopyArrayOfAllPeople(self.book).takeRetainedValue() as NSArray as [ABRecord]
        for person in people {
            let id = ABRecordGetRecordID(person) as Int32
            let apple_id = Int(id)

            var number = "";
            var numbers = [String]();
            let numbersRef: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
            var nameRef = ABRecordCopyCompositeName(person)

            if (nameRef == nil) {
                continue
            }

            let name = nameRef.takeRetainedValue() as String

            // TODO: Do foreach
            if (ABMultiValueGetCount(numbersRef) > 0) {

                if let phone = ABMultiValueCopyValueAtIndex(numbersRef, 0).takeRetainedValue() as? String {
                    numbers.append(phone)
                    number = phone
                }

            }

            contacts.append(["alias": name, "phone": number, "apple_id": String(id)])

            if (ABPersonHasImageData(person)) {
                if let imageRef = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail) {
                    self.cache[apple_id] = UIImage(data: imageRef.takeRetainedValue())
                } else {
                    self.cache[apple_id] = UserModel.getDefaultUserImage()
                }
            } else {
                if let linkedRef = ABPersonCopyArrayOfAllLinkedPeople(person) {
                    let linked = linkedRef.takeRetainedValue() as NSArray as [ABRecord]

                    if (linked.count > 0) {
                        for linkedUser: ABRecordRef in linked {
                            if (ABPersonHasImageData(linkedUser)) {
                                if let imageRef = ABPersonCopyImageDataWithFormat(linkedUser, kABPersonImageFormatThumbnail) {
                                    self.cache[apple_id] = UIImage(data: imageRef.takeRetainedValue())
                                    break
                                }
                            } else {
                                self.cache[apple_id] = UserModel.getDefaultUserImage()
                            }
                        }
                    } else {
                        self.cache[apple_id] = UserModel.getDefaultUserImage()
                    }

                }
            }
        }

        if (contacts.isEmpty) {
            return
        }

        UserModel.update(["contacts": contacts], closure: {result in
            println(result)
            closure?(true)
            }, errorHandler: {result in
                println(result)
                closure?(false)
        })
    }
}
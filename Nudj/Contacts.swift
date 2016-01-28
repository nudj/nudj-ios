//
//  AddressBook.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class Contacts {
    enum Notification: String {
        case ContactThumbnailReceived
    }
    
    enum ThumbnailKey: String {
        case Identifier
        case Image
    }
    
    let contactStore = CNContactStore()
    var imageCache = [String:UIImage]()

    func isAuthorized() -> Bool {
        let status = CNContactStore.authorizationStatusForEntityType(.Contacts)
        return status == .Authorized
    }
    
    func isBlocked() -> Bool {
        let status = CNContactStore.authorizationStatusForEntityType(.Contacts)
        return status == .Denied || status == .Restricted;
    }

    func getContactImageForId(identifier: String) -> UIImage? {
        if let cachedImage = self.imageCache[identifier] {
            return cachedImage
        }

        if (self.isBlocked()) {
            return nil
        }

        contactStore.requestAccessForEntityType(.Contacts) {
            success, error in
            guard success else {return}
            do {
                let contact = try self.contactStore.unifiedContactWithIdentifier(identifier, keysToFetch: [CNContactThumbnailImageDataKey])
                guard let thumbnail = contact.thumbnailImageData else {return}
                guard let image = UIImage(data: thumbnail) else {return}
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageCache[identifier] = image
                    self.notifyThumbnailChangeForContactWithId(identifier, newThumbnail: image)
                }
            }
            catch _ as NSError {
                // nothing
            }
        }

        return nil
    }
    
    func notifyThumbnailChangeForContactWithId(identifier: String, newThumbnail: UIImage) {
        let nc = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(
            name: Notification.ContactThumbnailReceived.rawValue, 
            object: self, 
            userInfo: [
                ThumbnailKey.Identifier.rawValue: identifier, 
                ThumbnailKey.Image.rawValue: newThumbnail
            ])
        nc.postNotification(notification)
    }
    
    // TODO: change notification from store CNContactStoreDidChangeNotification

    func sync(closure:((Bool) -> Void)? = nil) {
        if (self.isBlocked()) {
            return
        }

        contactStore.requestAccessForEntityType(.Contacts) {
            success, error in
            guard success else {return}
            do {
                let formatter = CNContactFormatter()
                formatter.style = .FullName
                
                let keysToFetch = [
                    CNContactFormatter.descriptorForRequiredKeysForStyle(formatter.style),
                    CNContactPhoneNumbersKey, 
                    CNContactIdentifierKey, 
                    CNContactThumbnailImageDataKey
                ]
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                fetchRequest.predicate = nil
                
                var contactsArray = [[String:String]]()
                var newImages = [String:UIImage]()
                
                try self.contactStore.enumerateContactsWithFetchRequest(fetchRequest) {
                    contact, stop in
                    guard let fullName = formatter.stringFromContact(contact) else {
                        return
                    }
                    let phones = contact.phoneNumbers
                    let firstPhone = phones.first?.value as? CNPhoneNumber
                    let firstPhoneNumber = firstPhone?.stringValue ?? ""
                    let identifier = contact.identifier
                    if let thumbnail = contact.thumbnailImageData {
                        if let image = UIImage(data: thumbnail) {
                            newImages[identifier] = image
                        }
                    }
                    
                    contactsArray.append(["alias": fullName, "phone": firstPhoneNumber, "apple_id": identifier])
                }
                
                UserModel.update(["contacts": contactsArray], closure: {
                    result in
                    closure?(true)
                    }, errorHandler: {
                        result in
                        closure?(false)
                })
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageCache = newImages
                    for (identifier, image) in newImages {
                        self.notifyThumbnailChangeForContactWithId(identifier, newThumbnail: image)
                    }
                }
            }
            catch {
                // nothing
            }
        }
    }
}

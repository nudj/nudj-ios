//
//  SharableMessageType.swift
//  Nudj
//
//  Created by Richard Buckle on 05/07/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

protocol SharableMessageType {
}

extension SharableMessageType where Self: UIViewController {
    func shareMessage(message: String, completionWithItemsHandler: UIActivityViewControllerCompletionWithItemsHandler) {
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityVC.completionWithItemsHandler = completionWithItemsHandler
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func shareJob(jobID: Int, isOwnJob: Bool) -> Void {
        let jobURL: JobURL = .Preview(jobID)
        let url = jobURL.url()
        let message: String
        if isOwnJob {
            message = Localizations.Jobs.Referral.Sms._Default.Format(url.absoluteString)
        } else {
            message = Localizations.Jobs.Nudj.Sms._Default.Format(url.absoluteString)
        }
        
        func handler(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) -> Void {
            if completed {
                MixPanelHandler.sendData(isOwnJob ? "Asked for Referral via \(activityType)" : "Sent Nudj via \(activityType)")
                let actualMessage = returnedItems?.first as? String ?? message
                let params = API.Endpoints.Nudge.paramsForJob(jobID, contactIDs: [], message: actualMessage, clientWillSend: true)
                let path = isOwnJob ? API.Endpoints.Nudge.ask : API.Endpoints.Nudge.base
                API.sharedInstance.request(.PUT, path: path, params: params){
                    error in
                    loggingPrint(error)
                }
            }
        }
        shareMessage(message, completionWithItemsHandler: handler)
    }
}

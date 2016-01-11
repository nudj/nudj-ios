//
//  VersionNumber.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

func fullVersionNumber() -> String {
    let bundle = NSBundle.mainBundle()
    let appName = (bundle.objectForInfoDictionaryKey("CFBundleDisplayName") ?? bundle.objectForInfoDictionaryKey("CFBundleName")) as! String
    let shortVersion = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    let build = bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
    let api = API()
    let serverName = api.server.description
    let fullVersion = Localizations.Version.Full.Format(appName, shortVersion, build, serverName)
    return fullVersion
}

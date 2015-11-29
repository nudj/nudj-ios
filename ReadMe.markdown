# nudj-iOS

This is the iOS app for Nudj.

## Crash reporting

Crash reporting is now done via [HockeyApp](http://hockeyapp.net/).

## Change log

The nightly build process uses the script `make-qa-log.py` in the root directory to create the change log for HockeyApp using the subject lines of all Git commits that are in `development` but not in `master`. The subject lines are interpreted as [Markdown](http://daringfireball.net/projects/markdown/syntax), ticket numbers in the form "#123" are hyperlinked to Assembla, and merge commits are shown in italics.

Therefore please add ticket numbers in the form "#123" to your commit message titles wherever relevant.

## Core Data Model

TODO

## Third-party dependencies

### Not (yet) in submodules

* AnimStep
* HockeySDK-iOS  
  Used for crash reporting and deployment to QA.  
  Version 3.8.5 licensed from [http://hockeyapp.net/]().
* iOSLinkedInAPI
* JSQMessagesViewController
* JSQSystemSoundPlayer
* KSTokenView
* LinkedIn
* NZLabel
* XMPPFramework

### In submodules

* LoggingPrint  
  Used to confine developer logging to debug builds of the app, to improve erformance of the release builds.

### In CocoaPods

* Alamofire, ~> 2.0
* SwiftyJSON, ~> 2.1
* FBSDKCoreKit
* FBSDKLoginKit
* FBSDKShareKit
* DateTools
* Mixpanel
* ReachabilitySwift, from [https://github.com/ashleymills/Reachability.swift]()
* CCMPopup

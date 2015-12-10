# nudj-iOS

This is the iOS app for Nudj.

## Crash reporting

Crash reporting is now done via [HockeyApp](http://hockeyapp.net/).

## Change log

Please add ticket numbers in the form "#123" to your commit message titles wherever relevant.

The nightly build process uses the script `make-qa-log.py` in the root directory to create the change log for HockeyApp using the subject lines of all Git commits that are in `development` but not in `master`. The text is interpreted as [Markdown](http://daringfireball.net/projects/markdown/syntax), ticket numbers in the form "#123" are hyperlinked to GitHub, and merge commits are shown in italics.

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
  Used to confine developer logging to debug builds of the app, to improve performance of the release builds.

### In CocoaPods

* Alamofire  
  Used for networking. Could probably be eliminated.
* SwiftyJSON, ~> 2.1
* Facebook APIs
	* FBSDKCoreKit
	* FBSDKLoginKit
	* FBSDKShareKit
* DateTools  
  To be eliminated per issue #11
* Mixpanel
* ReachabilitySwift, from [https://github.com/ashleymills/Reachability.swift]()
* CCMPopup

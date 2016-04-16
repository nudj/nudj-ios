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

* HockeySDK-iOS  
  Used for crash reporting and deployment to QA.  
  Version 3.8.5 licensed from [http://hockeyapp.net/]().
* JSQMessagesViewController
* JSQSystemSoundPlayer
* XMPPFramework

### In submodules

* Laurine  
  Supports compile-time checking of the loading of localised text.
* LoggingPrint  
  Used to confine developer logging to debug builds of the app, to improve performance of the release builds.
* KSTokenView
  Used for the skills field in job listings and user profiles.

### In CocoaPods

* SwiftyJSON
* Facebook APIs
	* FBSDKCoreKit
	* FBSDKLoginKit
	* FBSDKShareKit
* DateTools  
* Mixpanel

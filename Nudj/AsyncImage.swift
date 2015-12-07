//
//  AsyncImage.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class AsyncImage: UIImageView {
    // TODO: magic number
    let minimumBytes = 100

    let loader = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    @IBInspectable
    var blur:Bool = false

    @IBInspectable
    var blurRadius:CGFloat = 8

    @IBInspectable
    var circleShape:Bool = false

    @IBInspectable
    var borderWidth:CGFloat = 0

    @IBInspectable
    var borderAlpha:CGFloat = 0

    @IBInspectable
    var backgroundOverlay:CGFloat = 0
    var emptyBackgroundOverlay:CGFloat = 0.1

    @IBInspectable
    var backgroundOverlayColor:UIColor = UIColor.blackColor()

    var overlay:UIView?

    init() {
        super.init(image: nil, highlightedImage: nil)
        self.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }

    func prepare() {
        self.contentMode = .ScaleAspectFill

        if (self.circleShape) {
            self.layer.cornerRadius = self.layer.bounds.width / 2.0
            self.layer.masksToBounds = true

            self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: borderAlpha).CGColor
            self.layer.borderWidth = borderWidth
        }

        setOverlay()
    }

    func cleanOverlay() {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
    }

    func setOverlay() {
        cleanOverlay()

        if (self.backgroundOverlay > 0) {
            self.overlay = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height));
            self.overlay!.backgroundColor = backgroundOverlayColor;
            self.overlay!.alpha = image == nil ? emptyBackgroundOverlay : backgroundOverlay
            self.addSubview(self.overlay!)
        }
    }

    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        let session = NSURLSession.sharedSession();
        session.configuration.HTTPShouldSetCookies = false
        session.configuration.HTTPMaximumConnectionsPerHost = 8

        session.dataTaskWithURL(NSURL(string: url)!) { 
            (data, response, error) in
            completion(data: data)
        }.resume()
    }

    func downloadImage(url:String?, completion: (() -> Void)? = nil) {
        guard let url = url else {
            return
        }
        guard !url.isEmpty else {
            return
        }

        self.startActivity()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            self.getDataFromUrl(url) { data in
                dispatch_async(dispatch_get_main_queue()) {

                    if (data?.length <= self.minimumBytes) {
                        self.stopActivity()
                        return
                    }

                    self.setCustomImage(UIImage(data: data!))

                    if (completion != nil) {
                        completion!()
                    }
                }
            }
        }
    }

    func setCustomImage(image:UIImage?) {
        self.image = image

        if (self.blur && self.image != nil) {
            self.image = RBBlurImage(self.image!, radius: self.blurRadius)
        }

        self.stopActivity()

        if (self.overlay != nil) {
            self.bringSubviewToFront(self.overlay!)
        }

        self.prepare()
    }

    func startActivity() {
        self.addSubview(self.loader)
        self.loader.startAnimating()
        self.loader.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
    }

    func stopActivity() {
        self.loader.removeFromSuperview()
        self.loader.stopAnimating()
    }
}

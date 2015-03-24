//
//  AsyncImage.swift
//  Nudge
//
//  Created by Lachezar Todorov on 10.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class AsyncImage: UIImageView {

    let minimumBytes = 100

    let loader = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)

    var blur = false
    var blurRadius:CGFloat = 8
    var circleShape = false

    override init() {
        super.init()
        self.prepare()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }

    func prepare() {
        self.contentMode = UIViewContentMode.ScaleAspectFill

        if (self.circleShape) {
            self.layer.cornerRadius = self.layer.bounds.width/2
            self.layer.masksToBounds = true
        }
    }

    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }

    func downloadImage(url:String?, completion: (() -> Void)? = nil) {
        if (url == nil || countElements(url!) <= 0) {
            return
        }

        self.startActivity()

        getDataFromUrl(url!) { data in
            dispatch_async(dispatch_get_main_queue()) {

                if (data?.length <= self.minimumBytes) {
                    self.stopActivity()
                    return
                }

                self.image = UIImage(data: data!)

                if (self.blur && self.image != nil) {
                    self.image = RBBlurImage(self.image!, self.blurRadius)
                }

                self.stopActivity()

                if (completion != nil) {
                    completion!()
                }
            }
        }
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

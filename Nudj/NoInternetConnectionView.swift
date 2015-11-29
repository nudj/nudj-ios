//
//  NoInternetConnectionView.swift
//  Nudj
//
//  Created by Antonio on 23/08/2015.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class NoInternetConnectionView: UIView {

    // Our custom view from the XIB file
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        // TODO: JRB: this looks a bit suspect - review
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = self.frame
        
        // Make the view stretch with containing view
        /*view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight*/
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "NoInternetConnectionView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
}

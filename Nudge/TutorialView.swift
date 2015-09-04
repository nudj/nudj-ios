//
//  TutorialView.swift
//  Nudge
//
//  Created by Antonio on 04/09/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

protocol TutorialViewDelegate {
    
    func dismissTutorial()
    
}

class TutorialView: UIImageView {
    
    var delegate:TutorialViewDelegate?
    
    func starTutorial(name:String, view:UIView){
        
        self.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        let window = UIApplication.sharedApplication().keyWindow
        self.image = UIImage(named:name)
        self.userInteractionEnabled = true
        
        var gesture :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"stopTutorial");
        self.addGestureRecognizer(gesture)
        
        window!.addSubview(self)
   
    }
    
    
    func stopTutorial(){
        
        self.removeFromSuperview()
        delegate?.dismissTutorial()
    }
    
    
}

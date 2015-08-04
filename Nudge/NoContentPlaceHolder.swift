//
//  NoContentPlaceHolder.swift
//  Nudge
//
//  Created by Antonio on 04/08/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class NoContentPlaceHolder: UIImageView {

    init(view :UIView, imageTitle:String){
        
        super.init(frame:CGRectMake((view.frame.size.width/2) - 200/2 , (view.frame.size.height/2) - 149/2, 200,149))
        self.image = UIImage(named: imageTitle)
        self.hidden = true;
        
        view.addSubview(self)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPlaceholder(){
        
        self.hidden = false
        
    }
    
    func hidePlaceholder(){
        
        self.hidden = true
    }

}

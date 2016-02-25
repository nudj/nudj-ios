//
//  CenteredButton.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit

@IBDesignable
class CenteredButton: UIButton
{
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect
    {
        let rect = super.titleRectForContentRect(contentRect)
        
        return CGRectMake(0, CGRectGetHeight(contentRect) - CGRectGetHeight(rect), CGRectGetWidth(contentRect), CGRectGetHeight(rect))
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect
    {
        let rect = super.imageRectForContentRect(contentRect)
        let titleRect = titleRectForContentRect(contentRect)
        
        return CGRectMake(CGRectGetWidth(contentRect)/2.0 - CGRectGetWidth(rect)/2.0,
            (CGRectGetHeight(contentRect) - CGRectGetHeight(titleRect))/2.0 - CGRectGetHeight(rect)/2.0, CGRectGetWidth(rect), CGRectGetHeight(rect))
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        let size = super.intrinsicContentSize()
        
        if let imageView = self.imageView, image = imageView.image
        {
            var labelHeight: CGFloat = 0.0
            
            if let size = titleLabel?.sizeThatFits(CGSizeMake(CGRectGetWidth(self.contentRectForBounds(self.bounds)), CGFloat.max))
            {
                labelHeight = size.height
            }
            
            return CGSizeMake(max(size.width, imageView.bounds.width), image.size.height + labelHeight + imageEdgeInsets.bottom + titleEdgeInsets.top)
        }
        
        return size
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
    
    private func centerTitleLabel()
    {
        self.titleLabel?.textAlignment = .Center
    }
}

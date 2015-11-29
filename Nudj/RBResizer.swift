//
//  RBResizer.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage? {
    return RBResizeImage(RBSquareImage(image), targetSize: size)
}

func RBSquareImage(image: UIImage) -> UIImage? {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height

    let edge: CGFloat = min(originalHeight, originalWidth)

    let posX = (originalWidth  - edge) / 2.0
    let posY = (originalHeight - edge) / 2.0

    let cropSquare = CGRectMake(posX, posY, edge, edge)

    guard let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare) else {
        return nil
    }
    return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
}

func RBResizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
    guard let image = image else {
        return nil
    }
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}


func RBResizeCropImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
    guard let image = image else {
        return nil
    }
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    var imageSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * heightRatio)
        imageSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        y = CGFloat(newSize.height - size.height * widthRatio) / 2
    } else {
        newSize = CGSizeMake(size.width * heightRatio, size.height * widthRatio)
        imageSize = CGSizeMake(size.width * heightRatio,  size.height * heightRatio)
        x = CGFloat(newSize.width - size.width * heightRatio) / 2
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(x, y, imageSize.width, imageSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

func RBBlurImage(originalImage: UIImage, radius: CGFloat) -> UIImage {
    // preparation for blurring
    let ciContext = CIContext(options: nil)
    let ciImage = CIImage(image: originalImage) ?? CIImage.emptyImage()
    let ciFilter = CIFilter(name: "CIGaussianBlur")!

    ciFilter.setValue(ciImage, forKey: kCIInputImageKey)

    // actual blur, can be done many times with different
    // radiuses without running preparation again
    ciFilter.setValue(radius, forKey: "inputRadius")
    
    let blurredImage = ciFilter.outputImage ?? CIImage.emptyImage()

    return UIImage(CGImage: ciContext.createCGImage(blurredImage, fromRect: ciImage.extent))
}

//
//  UIImage+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-18.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreML

extension UIImage {
  /// Resizes the images for us so that it's set perfectly
  func resize(to newSize: CGSize) -> UIImage? {
    // has the scaled rects
    var scaledImageRect = CGRect.zero
    
    let aspectWidth = newSize.width / self.size.width
    let aspectHeight = newSize.height / self.size.height
    let aspectRatio = min(aspectWidth, aspectHeight)
    
    scaledImageRect.size.width = self.size.width * aspectRatio
    scaledImageRect.size.height = self.size.height * aspectRatio
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    self.draw(in: scaledImageRect)
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
  
  /// Prepare a pixel-like buffer, which helps us compress a bunch of pixels
  func pixelBuffer() -> CVPixelBuffer? {
    
    let width = Int(self.size.width)
    let height = Int(self.size.height)
    // retrieve the specific attributes that we want
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer: CVPixelBuffer?
    
    // create the pixelated image, with ARGB values
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard status == kCVReturnSuccess else {
      return nil
    }
    // prepares the buffer lock flags for us
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    /// Make sure this is in RGB
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
      return nil
    }
    
    // scale and test
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1.0, y: -1.0)
    
    // actually draw the graphical image
    UIGraphicsPushContext(context)
    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    return pixelBuffer
  }
  
  /// Checks if the specified images are not safe for work
  static func isPictureNSFW(images: [UIImage]) -> Bool {
    return images.map { asset -> Bool in
      let model = Nudity()
      
      //We need to set it to dimensions of 224, because of the algorithm
      guard let buffer = asset.resize(to: CGSize(width: 224, height: 224))?.pixelBuffer() else {
        fatalError("Scaling or converting to pixel buffer failed!")
      }
      
      guard let result = try? model.prediction(data: buffer) else {
        fatalError("Prediction failed!")
      }
      
      //If the image(s) given each have less than 20% NSFW content, return
      if result.classLabel == "SFW" && result.prob["\(result.classLabel)"]! * 100.0 >= 80 {
        return true
      }
      return false
      }.contains(!true)
  }
}

//
//  GH_GIFImageView.swift
//  SwiftyRefresh
//
//  Created by guanghuiwu on 16/5/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import ImageIO
import Foundation

class GHGIFImageView: UIImageView {
    
    var gifPath : String!
    var gifData : NSData!
    private(set) var isGifPlaying : Bool = false
    
    var frameCount : Int = 0                        // 图片帧数
    private var index : Int = 0                     // 图片索引
    private var timestamp : CFTimeInterval = 0
    private var imgSourceRef : CGImageSourceRef!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startGif() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            if !GHGIFManager.sharedInstance().hashTable.containsObject(self) {
                if self.gifData != nil || self.gifPath != nil {
                    if self.gifData != nil {
                        self.imgSourceRef = CGImageSourceCreateWithData(self.gifData, nil)
                    } else {
                        self.imgSourceRef = CGImageSourceCreateWithURL(NSURL(fileURLWithPath:self.gifPath), nil);
                    }
                    if self.imgSourceRef == nil { return }
                    dispatch_async(dispatch_get_main_queue(), { 
                        GHGIFManager.sharedInstance().hashTable.addObject(self)
                        self.frameCount = CGImageSourceGetCount(self.imgSourceRef)
                        self.index = self.frameCount
                    })
                }
            }
        }
        
        if (GHGIFManager.sharedInstance().displayLink) == nil {
            GHGIFManager.sharedInstance().displayLink = CADisplayLink.init(target: GHGIFManager.sharedInstance(), selector: #selector(GHGIFManager.sharedInstance().play))
            GHGIFManager.sharedInstance().displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
        isGifPlaying = true
    }
    
    func stopGif() {
        isGifPlaying = false
        GHGIFManager.sharedInstance().stopGifView(self)
    }
    
    func play() {
        forwardPlay(index)
    }
    
    // 帧前进
    func forwardPlay(currentIndex:Int) {
        index = currentIndex <= 0 ? frameCount : currentIndex
        playWithIndex(index,type: 1)
    }
    
//    // 帧后退
//    func backwardPlay(currentIndex:Int) {
//        index = currentIndex <= 0 ? frameCount : currentIndex
//        playWithIndex(index,type: -1)
//    }

    private func playWithIndex(currentIndex:Int ,type:Int) {
        if frameCount > 0 {
            let nextFrameDuration = frameDurationAtIndex(min(currentIndex, frameCount-1))
            if timestamp < nextFrameDuration {
                timestamp = GHGIFManager.sharedInstance().displayLink.duration + (timestamp)
                return
            }
            if imgSourceRef != nil {
                index = (index + (type)) % frameCount
                if index >= 0 {
                    let cgImage = CGImageSourceCreateImageAtIndex(imgSourceRef, index, nil)
                    self.layer.contents = cgImage
                    timestamp = 0
                }
            }
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.stopGif()
    }
    
    func frameDurationAtIndex(index:Int) -> Double {
        if imgSourceRef != nil {
            let cfDict = CGImageSourceCopyPropertiesAtIndex(imgSourceRef, index, nil)
            if cfDict != nil {
                let gifDict : CFDictionaryRef = unsafeBitCast(CFDictionaryGetValue(cfDict, unsafeAddressOf(kCGImagePropertyGIFDictionary)), AnyObject.self) as! CFDictionaryRef
                var delayTime : AnyObject = unsafeBitCast(
                    CFDictionaryGetValue(gifDict,
                        unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)),
                    AnyObject.self)
                
                if delayTime.doubleValue == 0 {
                    delayTime = unsafeBitCast(CFDictionaryGetValue(gifDict,
                        unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
                }
                if delayTime.doubleValue != 0 { return delayTime.doubleValue }
            }
        }
        return 1/24.0
    }
}

class GHGIFManager : NSObject {
    private var displayLink : CADisplayLink!
    private var hashTable : NSHashTable!
    
    private static let _sharedInstance = GHGIFManager()
    class func sharedInstance() -> GHGIFManager { return _sharedInstance }
    private override init() { hashTable = NSHashTable.weakObjectsHashTable() }

    func play() {
        for (_,object) in hashTable.allObjects.enumerate() {
            let imgView = object as! GHGIFImageView
            imgView.performSelector(#selector(GHGIFImageView.play))
        }
    }
    
    func stopDisplayLink() {
        if (displayLink != nil) {
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    func stopGifView(imgView:GHGIFImageView) {
        hashTable.removeObject(imgView)
        if hashTable.count < 1 && displayLink != nil {
//            stopDisplayLink()
        }
    }
}
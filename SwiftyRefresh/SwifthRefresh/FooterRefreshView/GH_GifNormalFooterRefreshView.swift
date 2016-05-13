//
//  GH_GifNormalFooterRefreshView.swift
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

class GHGifNormalFooterRefreshView: GH_BaseFooterView {
    
    override func beginFooterRefresh() {
        super.beginFooterRefresh()
        dispatchAfter(0) { () -> Void in
            if let superview = self.superview as? UIScrollView where !self.isfooterRefreshing {
                superview.userInteractionEnabled = false
                self.isfooterRefreshing = true
                self.footerContentInsets = superview.contentInset
                let currentOffset = superview.contentOffset
                if !self.isSuperviewHeightAlwaysChanging {
                    self.changeRefreshingFooterFrame(currentOffset, superview: superview)
                }
                self.footerForbidsOffsetChanges = true
            }
        }
    }
    
    override func endFooterRefresh() {
        super.endFooterRefresh()
        var duration : CGFloat = 0
        if isSuperviewHeightAlwaysChanging { duration = 1 }
        dispatchAfter(duration) { () -> Void in
            if let superview = self.superview as? UIScrollView where self.isfooterRefreshing{
                self.isfooterRefreshing = false
                self.footerForbidsOffsetChanges = false
                superview.userInteractionEnabled = false
                if self.dataType == .NoMoreData {
                    self.viewAnmationWithDurantion(0.2, superview: superview)
                } else {
                    self.viewAnmationWithDurantion(0.2, superview: superview)
                }
            }
        }
    }
    
    private static let _sharedInstance = GHGifNormalFooterRefreshView()
    class func sharedInstance() -> GHGifNormalFooterRefreshView { return _sharedInstance }
    private override init(frame: CGRect) { super.init(frame: frame); initSubViews() }
    internal required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initSubViews() }
    
    // MARK: - internal
    internal override var contentMode: UIViewContentMode {
        get { return gifImageView.contentMode }
        set { gifImageView.contentMode = newValue }
    }
    
    private func initSubViews() {
        addSubview(gifImageView)
        gifImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentMode = .ScaleAspectFit
        gifImageView.frame = bounds
        backgroundColor = bgColor()
    }
    
    deinit { gifImageView.stopGif() }
    private func viewAnmationWithDurantion(duration:NSTimeInterval,superview:UIScrollView) {
        UIView.animateWithDuration(duration, delay: 0.2, options: .CurveLinear, animations: {
            if let contentInset = self.footerContentInsets {
                superview.contentInset = contentInset
                self.footerContentInsets = nil
                self.frame = CGRectMake(0, superview.contentSize.height, superview.width, 0)
            }
            if (self.gifImageView.isGifPlaying) { self.gifImageView.stopGif() }
            }, completion: { (complete) in
                superview.userInteractionEnabled = true
        })
    }

    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == GHREFRESH_ContentOffsetKey && !footerChangingInset { changeFooterContentOffset() }
        if keyPath == GHREFRESH_ContentSizeKey && !footerChangingInset { changeFooterContentSize() }
    }
    
    private func changeFooterContentSize() {
        if let superview = self.superview as? UIScrollView where isfooterRefreshing && isSuperviewHeightAlwaysChanging  {
            if !superview.tracking && !superview.dragging && superview.decelerating {
                let currentOffset = superview.contentOffset
                changeRefreshingFooterFrame(currentOffset, superview: superview)
                superview.userInteractionEnabled = false
                footerForbidsOffsetChanges = true
                isfooterRefreshing = true
            }
        }
    }
    
    private func changeFooterContentOffset() {
        if let superview = superview as? UIScrollView {
            let maxheight = superview.contentSize.height
            let offsetY = superview.contentOffset.y
            let height = superview.height
            
            if maxheight <= height - expandedFooterHeight { return }
            
            let minheight = maxheight - height
            var originY = offsetY - minheight
            originY = originY < 0 ? 0 : originY
            
            if isfooterRefreshing {  if originY == 0 { endFooterRefresh(); return } }
            frame = CGRectMake(0,  maxheight, superview.width, originY)
            
            if originY >= expandedFooterHeight {
                if !footerStatusChanged { footerStatusChanged = true }
                else { footerForbidsInsetChanges = true }
            } else {
                if footerStatusChanged { footerStatusChanged = false }
                else { if !isfooterRefreshing { footerForbidsInsetChanges = false } }
            }
            
            if !isfooterRefreshing && originY >= 0 {
                let indexFrameCount = (CGFloat(gifImageView.frameCount ?? 1) - 1) * 2
                let percentage = min(indexFrameCount, (fabs(originY) / GHREFRESH_MaxFooterHeight))
                let currentIndex = Int(indexFrameCount * percentage) % GHREFRESH_MaxFrameCount
                if (gifImageView.isGifPlaying) { gifImageView.forwardPlay(currentIndex) }
                else { gifImageView.startGif() }
            }

            if superview.tracking { footerForbidsInsetChanges = false }
            if !superview.dragging && superview.decelerating && !footerForbidsOffsetChanges && footerForbidsInsetChanges {
                beginFooterRefresh()
            }
        }
    }
}

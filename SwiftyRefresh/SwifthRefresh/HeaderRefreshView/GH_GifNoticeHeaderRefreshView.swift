//
//  GH_GifNoticeHeaderRefreshView.swift
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

class GHGifNoticeHeaderRefreshView: GH_BaseHeaderView {
    
    override func beginHeaderRefresh() {
        super.beginHeaderRefresh()
        dispatchAfter(0) { () -> Void in
            if let superview = self.superview as? UIScrollView where !self.isheaderRefreshing {
                self.headerContentInsets = superview.contentInset
                let currentOffset = superview.contentOffset
                superview.userInteractionEnabled = false
                self.isheaderRefreshing = true
                self.headerChangingInset = true
                self.frame = CGRectMake(0, 0, superview.width, self.expandedHeaderHeight)
                
                var contentInset = superview.contentInset
                contentInset.top = contentInset.top + self.expandedHeaderHeight
                superview.contentInset = contentInset
                self.headerChangingInset = false
                if !self.isSuperviewHeightAlwaysChanging {
                    superview.setContentOffset(CGPoint(x: 0, y: currentOffset.y - 1), animated: false)
                    superview.setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: self.isheaderRefreshAnimated)
                } else {
                    superview.setContentOffset(CGPoint(x: 0, y: self.expandedHeaderHeight - 1), animated: false)
                    superview.setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: false)
                }
                self.isheaderRefreshAnimated = false
                self.headerForbidsOffsetChanges = true
            }
        }
    }
    
    override func endHeaderRefresh() {
        super.endHeaderRefresh()
        dispatchAfter(0) { () -> Void in
            if let superview = self.superview as? UIScrollView where self.isheaderRefreshing {
                superview.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveLinear, animations: {
                    self.messageLabel.text = GHREFRESH_headerRefreshEnd
                    }, completion: { (complet) in
                        if complet {
                            UIView.animateWithDuration(0.5,  delay: 0.5, options: .CurveLinear,animations: {
                                    if let contentInset = self.headerContentInsets {
                                        superview.contentInset = contentInset
                                        self.headerContentInsets = nil
                                        self.frame = CGRectMake(0, 0, superview.width, 0)
                                        let width = superview.width / 3
                                        self.messageLabel.frame = CGRectMake(width, 0, width, -GHREFRESH_MLabelHeight * 0.6)
                                        self.gifImageView.frame = CGRectMake(self.messageLabel.x - width + GH_ScaleScreen(30), 0, width, 0)
                                    }
                                }, completion: { (complet) in
                                    if complet {
                                        self.isheaderRefreshing = false
                                        self.headerForbidsOffsetChanges = false
                                        superview.userInteractionEnabled = true
                                        if (self.gifImageView.isGifPlaying) { self.gifImageView.stopGif() }
                                    }
                            })
                        }
                })
            }
        }
    }
    
    // MARK: - init
    private static let _sharedInstance = GHGifNoticeHeaderRefreshView()
    class func sharedInstance() -> GHGifNoticeHeaderRefreshView { return _sharedInstance }
    private override init(frame: CGRect) { super.init(frame: frame); initSubViews() }
    internal required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initSubViews() }
    
    // MARK: - internal
    internal override var contentMode: UIViewContentMode {
        get { return gifImageView.contentMode }
        set { gifImageView.contentMode = newValue }
    }
    
    // MARK: - private & override
    private func initSubViews() {
        addSubview(gifImageView)
        addSubview(messageLabel)
        gifImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentMode = .ScaleAspectFit
        gifImageView.frame = bounds
        backgroundColor = bgColor()
    }
    deinit { gifImageView.stopGif() }
    private var expandedHeaderHeight: CGFloat {
        var height = gifImageView.frame.size.height
        if height >= GHREFRESH_MaxHeaderHeight { height = GHREFRESH_MaxHeaderHeight }
        return max(GHREFRESH_MaxHeaderHeight, height ?? GHREFRESH_MaxHeaderHeight)
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == GHREFRESH_ContentOffsetKey && !headerChangingInset { changeHeaderContentOffset() }
    }
    
    private func changeHeaderContentOffset() {
        if let superview = superview as? UIScrollView {
            let topInset = (headerContentInsets ?? superview.contentInset).top
            let originY = superview.contentOffset.y + topInset
            let width = superview.width / 3
            
            var height = originY
            height = height > 0 ? 0 : height
            if isheaderRefreshing { if originY == 0 { endHeaderRefresh(); return } }
            
            frame = CGRectMake(0, originY, width * 3, -height)
            var offY = (frame.height - GHREFRESH_MLabelHeight)
            if -height >= 20 { offY = offY * 0.5 }
            messageLabel.frame = CGRectMake(width, offY, width, GHREFRESH_MLabelHeight)
            gifImageView.frame = CGRectMake(messageLabel.x - width + GH_ScaleScreen(30), 0, width, -height)
            
            if originY <= -expandedHeaderHeight {
                if !topAnchorDownToUp { topAnchorDownToUp = true }
                else { headerForbidsInsetChanges = true }
            } else {
                if topAnchorDownToUp { topAnchorDownToUp = false }
                else { if !isheaderRefreshing { headerForbidsInsetChanges = false } }
            }
            
            if superview.tracking { headerForbidsInsetChanges = false }
            
            if originY <= -expandedHeaderHeight {
                messageLabel.text = GHREFRESH_headerWillRefresh
            } else {
                if superview.dragging {
                    messageLabel.text = GHREFRESH_headerPrepareRefresh
                }
            }
            
            if messageLabel.text == GHREFRESH_headerWillRefresh {
                headerForbidsInsetChanges = true
            } else { headerForbidsInsetChanges = false }
            
            if isheaderRefreshing { messageLabel.text = GHREFRESH_headerRefreshIng }
            
            if !isheaderRefreshing && superview.contentOffset.y + topInset < 0 {
                let indexFrameCount = (CGFloat(gifImageView.frameCount ?? 1) - 1) * 2
                let percentage = min(indexFrameCount, (fabs(height) / GHREFRESH_MaxHeaderHeight))
                let currentIndex = Int(indexFrameCount * percentage) % GHREFRESH_MaxFrameCount
                if originY < 0.0 {
                    if (gifImageView.isGifPlaying) { gifImageView.forwardPlay(currentIndex) }
                    else { gifImageView.startGif() }
                }
            }
            
            if !superview.dragging && superview.decelerating && !headerForbidsOffsetChanges && headerForbidsInsetChanges {
                isheaderRefreshAnimated = true
                beginHeaderRefresh()
            }
        }
    }
}


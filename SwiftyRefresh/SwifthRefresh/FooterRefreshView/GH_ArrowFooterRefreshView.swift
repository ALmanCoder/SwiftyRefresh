//
//  GH_ArrowFooterRefreshView.swift
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

class GHArrowFooterRefreshView: GH_BaseFooterView {
    
    override func beginFooterRefresh() {
        super.beginFooterRefresh()
        dispatchAfter(0) { () -> Void in
            self.anchorImgView.hidden = true
            self.indicatorView.startAnimating()
            self.messageLabel.text = GHREFRESH_footerRefreshIng
            if let superview = self.superview as? UIScrollView where !self.isfooterRefreshing {
                superview.userInteractionEnabled = false
                self.indicatorView.startAnimating()
                self.anchorImgView.hidden = true
                self.isfooterRefreshing = true
                self.footerContentInsets = superview.contentInset
                let currentOffset = superview.contentOffset
                self.changeRefreshingFooterFrame(currentOffset, superview: superview)
                self.footerForbidsOffsetChanges = true
            }
        }
    }
    
    override func endFooterRefresh() {
        super.endFooterRefresh()
        dispatchAfter(0) { () -> Void in
            self.anchorImgView.transform = CGAffineTransformMakeRotation(GHREFRESH_TransformAngle)
            if let superview = self.superview as? UIScrollView where self.isfooterRefreshing{
                self.isfooterRefreshing = false
                self.footerForbidsOffsetChanges = false
                superview.userInteractionEnabled = false
                self.anchorImgView.hidden = false
                if self.indicatorView.isAnimating() { self.indicatorView.stopAnimating() }
                
                if self.dataType == .NoMoreData {
                    self.messageLabel.text = GHREFRESH_footerNoMoreData
                    self.viewAnmationWithDurantion(0.5, superview: superview)
                } else {
                    self.messageLabel.text = GHREFRESH_footerRefreshEnd
                    self.viewAnmationWithDurantion(0.3, superview: superview)
                }
            }
        }
    }
    
    private static let _sharedInstance = GHArrowFooterRefreshView()
    class func sharedInstance() -> GHArrowFooterRefreshView { return _sharedInstance }
    private override init(frame: CGRect) { super.init(frame: frame); initSubViews() }
    internal required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initSubViews() }
    
    private func initSubViews() {
        addSubview(anchorImgView)
        addSubview(messageLabel)
        addSubview(indicatorView)
        anchorImgView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentMode = .ScaleAspectFit
        backgroundColor = bgColor()
    }
    
    private func viewAnmationWithDurantion(duration:NSTimeInterval,superview:UIScrollView) {
        UIView.animateWithDuration(duration, delay: 0.2, options: .CurveLinear, animations: {
            if let contentInset = self.footerContentInsets {
                superview.contentInset = contentInset
                let width = superview.width
                self.footerContentInsets = nil
                self.frame = CGRectMake(0, superview.contentSize.height, width, 0)
                self.messageLabel.frame = CGRectMake(width / 3, -0, width / 3, GHREFRESH_MImgHeight)
                let offx = self.messageLabel.x - GHREFRESH_MImgHeight
                self.anchorImgView.frame = CGRectMake(offx, -0, GHREFRESH_MImgHeight, GHREFRESH_MImgHeight)
            }
            }, completion: { (complete) in
                superview.userInteractionEnabled = true
        })
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == GHREFRESH_ContentOffsetKey && !footerChangingInset { changeFooterContentOffset() }
    }
    
    private func changeFooterContentOffset() {
        if let superview = superview as? UIScrollView {
            let height = superview.height
            let width = superview.width
            let offsetY = superview.contentOffset.y
            let maxheight = superview.contentSize.height
            
            if maxheight <= height - expandedFooterHeight { return }
            
            let minheight = maxheight - height
            var originY = offsetY - minheight
            originY = originY < 0 ? 0 : originY
            
            if isfooterRefreshing {  if originY == 0 { endFooterRefresh(); return } }
            frame = CGRectMake(0,  maxheight, width, originY)
            
            var offY = (originY - GHREFRESH_MImgHeight)
            if originY >= GHREFRESH_MImgHeight { offY = offY * 0.5 }
            else { offY = -offY * 0.5 }
            
            messageLabel.frame = CGRectMake(width / 3, offY, width / 3, GHREFRESH_MImgHeight)
            let offx = messageLabel.x - GHREFRESH_MImgHeight
            anchorImgView.frame = CGRectMake(offx, offY, GHREFRESH_MImgHeight, GHREFRESH_MImgHeight)
            indicatorView.center = anchorImgView.center
            
            // 根据有无更多数据判断下一次刷新前显示的状态
            if originY >= expandedFooterHeight * 0.001 {
                if !footerStatusChanged { footerStatusChanged = true }
                else { footerForbidsInsetChanges = true }
            } else {
                if footerStatusChanged { footerStatusChanged = false }
                else { if !isfooterRefreshing { footerForbidsInsetChanges = false } }
            }
            
            if originY >= expandedFooterHeight {
                messageLabel.text = GHREFRESH_footerWillRefresh
                UIView.animateWithDuration(GHREFRESH_AnchorDuration, animations: {
                    self.anchorImgView.transform = CGAffineTransformIdentity
                })
                anchorImgView.hidden = false
            } else {
                if superview.dragging {
                    if dataType == .NoMoreData {
                        messageLabel.text = GHREFRESH_footerNoMoreData
                        UIView.animateWithDuration(GHREFRESH_AnchorDuration, animations: {
                            self.anchorImgView.transform = CGAffineTransformMakeRotation(GHREFRESH_TransformAngle)
                        })
                    } else {
                        messageLabel.text = GHREFRESH_footerPrepareRefresh
                        UIView.animateWithDuration(GHREFRESH_AnchorDuration, animations: {
                            self.anchorImgView.transform = CGAffineTransformMakeRotation(GHREFRESH_TransformAngle)
                        })
                    }
                }
            }
            
            if superview.tracking { footerForbidsInsetChanges = false }
            
            // 避免状态语和是否要刷新不一致的正确姿势
            if messageLabel.text == GHREFRESH_footerWillRefresh {
                footerForbidsInsetChanges = true
            } else { footerForbidsInsetChanges = false }
            
            if isfooterRefreshing && dataType == .HaveMoreData {
                self.indicatorView.startAnimating()
                anchorImgView.hidden = true
            }
            if indicatorView.isAnimating() {
                self.messageLabel.text = GHREFRESH_footerRefreshIng
                anchorImgView.hidden = true
            }
            
            if !isfooterRefreshing && !superview.dragging && superview.decelerating && !footerForbidsOffsetChanges && footerForbidsInsetChanges {
                beginFooterRefresh()
            }
        }
    }
}

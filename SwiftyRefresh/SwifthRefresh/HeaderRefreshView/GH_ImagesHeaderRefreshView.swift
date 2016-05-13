//
//  GH_ImagesHeaderRefreshView.swift
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

class GHImagesHeaderRefreshView: GH_BaseHeaderView {
    
    var imageName : String = "" {
        didSet{
            animationImgView.image = UIImage(named: imageName)
        }
    }
    
    // MARK: - 开始刷新
    override func beginHeaderRefresh() {
        super.beginHeaderRefresh()
        dispatchAfter(0) { () -> Void in
            if let superview = self.superview as? UIScrollView where !self.isheaderRefreshing {
                superview.userInteractionEnabled = false
                self.startHeaderRefreshImagesAnimation()
                
                self.isheaderRefreshing = true
                self.headerContentInsets = superview.contentInset
                let currentOffset = superview.contentOffset
                
                self.headerChangingInset = true
                self.frame = CGRectMake(0, 0, superview.frame.width, self.expandedHeaderHeight)
                
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
    
    // MARK: - 结束刷新
    override func endHeaderRefresh() {
        dispatchAfter(0) { () -> Void in
            if let superview = self.superview as? UIScrollView where self.isheaderRefreshing {
                superview.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveLinear, animations: {
                        self.messageLabel.text = GHREFRESH_headerRefreshEnd
                        self.imageName = "dropdown_anim__00060"
                    }, completion: { (complet) in
                        if complet {
                            UIView.animateWithDuration(0.5,  delay: 0.5, options: .CurveLinear,animations: {
                                if let contentInset = self.headerContentInsets {
                                    self.stopHeaderRefreshImagesAnimation()
                                    superview.contentInset = contentInset
                                    self.headerContentInsets = nil
                                    self.frame = CGRectMake(0, 0, superview.width, 0)
                                    self.messageBgView.y = -GHREFRESH_MImgHeight
                                    let offx = self.messageBgView.x - GHREFRESH_MImgWidth * 3
                                    self.animationImgView.frame = CGRectMake(offx, -GHREFRESH_MImgHeight, GHREFRESH_MImgHeight, GHREFRESH_MImgHeight)
                                }
                                }, completion: { (complet) in
                                    if complet {
                                        // 更新最后的刷新时间
                                        saveTime()
                                        self.isheaderRefreshing = false
                                        self.headerForbidsOffsetChanges = false
                                        self.superview!.userInteractionEnabled = true
                                    }
                            })
                        }
                })
            }
        }
    }
    
    // MARK: - add refreshing images
    private func startHeaderRefreshImagesAnimation() {
        if animationImages.count == 0 {
            if !animationImgView.isAnimating() {
                for i in 1..<4 {
                    let image = UIImage(named: "dropdown_loading_0\(i)")
                    animationImages.append(image!)
                }
                animationImgView.animationImages = animationImages
                animationImgView.animationDuration = 1
            }
        }
        animationImgView.startAnimating()
    }

    private func stopHeaderRefreshImagesAnimation() {
        if animationImgView.isAnimating() {
            animationImgView.stopAnimating()
        }
    }
    
    // MARK: - init
    private static let _sharedInstance = GHImagesHeaderRefreshView()
    class func sharedInstance() -> GHImagesHeaderRefreshView { return _sharedInstance }
    private override init(frame: CGRect) { super.init(frame: frame); initSubViews() }
    internal required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initSubViews() }
    
    // MARK: - private & override
    private func initSubViews() {
        addSubview(animationImgView)
        addSubview(messageBgView)
        messageBgView.addSubview(messageLabel)
        messageBgView.addSubview(updateLabel)
        animationImgView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentMode = .ScaleAspectFit
        backgroundColor = bgColor()
    }
    
    private var expandedHeaderHeight: CGFloat {
        var height = animationImgView.frame.size.height
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
            let width = superview.width
            var height = originY
            height = height > 0 ? 0 : height
            
            if isheaderRefreshing { if originY == 0 { endHeaderRefresh(); return } }
            
            frame = CGRectMake(0, originY, width, -height)
            
            var offY = (frame.height - GHREFRESH_MImgHeight)
            if -height >= GHREFRESH_MImgHeight { offY = offY * 0.5 }
            
            updateLabel.text = getLastUpdateTime()
            messageBgView.frame = CGRectMake(width/3, offY, width/3, messageBgView.height)
            let offx = messageBgView.x - GHREFRESH_MImgWidth * 3
            animationImgView.frame = CGRectMake(offx, offY, GHREFRESH_MImgHeight, GHREFRESH_MImgHeight)
            messageLabel.width = messageBgView.width
            updateLabel.width = messageBgView.width
            
            var index = -Int(originY)
            index = index > GHREFRESH_MaxImgsCount ? GHREFRESH_MaxImgsCount : index
            index = index < 0 ? 0 :index
            imageName = "dropdown_anim__000\(index)"
            
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
            if !superview.dragging && superview.decelerating && !headerForbidsOffsetChanges && headerForbidsInsetChanges {
                isheaderRefreshAnimated = true
                beginHeaderRefresh()
            }
        }
    }
}

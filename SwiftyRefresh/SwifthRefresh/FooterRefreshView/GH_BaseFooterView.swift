//
//  GH_BaseFooterView.swift
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

//  FooterView 工厂

import UIKit

class GH_BaseFooterView: UIControl {

    var footerContentInsets : UIEdgeInsets!
    var footerForbidsOffsetChanges = false
    var footerForbidsInsetChanges = false
    var footerChangingInset = false
    var isfooterRefreshing = false
    var footerStatusChanged = false
    
    // return 44 + CGFloat(arc4random() % 100)
    var isSuperviewHeightAlwaysChanging = false
    
    // MARK: - make sure the value of ".ValueChanged" is changed, the Selector of "footerRefresh" is only run once
    var isValueChanged = false
    var dataType : GHFooterRefreshDataType = .HaveMoreData
    
    // MARK: - 消息提示
    lazy var messageLabel : UILabel = {
        let messageLabel = UILabel(frame:CGRectZero)
        messageLabel.textAlignment = .Center
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.font = UIFont.systemFontOfSize(14)
        return messageLabel
    }()
    
    // MARK: - 菊花
    lazy var indicatorView : UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    // MARK: - 箭头
    lazy var anchorImgView : UIImageView = {
        let anchorImgView = UIImageView(image: UIImage(named: getImageFromRefreshBundle("arrow")))
        anchorImgView.backgroundColor = UIColor.clearColor()
        anchorImgView.contentMode = .Center
        return anchorImgView
    }()
    
    // MARK: - gif控件
    lazy var gifImageView : GHGIFImageView = {
        let gifView = GHGIFImageView.init(frame:.zero)
        gifView.backgroundColor = UIColor.clearColor()
        return gifView
    }()
    
    // set gif image
    var gifImageName : String = "" {
        didSet{
            if gifImageName == "" { gifImageName = "paobu" } // 默认值
            let gifData : NSData = loadGifFromRefreshBoundle(gifImageName, type: "gif")
            gifImageView.gifData = gifData
        }
    }
    
    // MARK: - private & override
    internal func addFooterRefreshView(superview:AnyObject, target:AnyObject ,action:Selector) {
        if let superview = superview as? UIScrollView {
            removeTarget(target, action: action, forControlEvents: .ValueChanged)
            self.removeFromSuperview()
            addTarget(target, action: action, forControlEvents: .ValueChanged)
            superview.addSubview(self)
            superview.sendSubviewToBack(self)
        }
    }
    
    internal func beginFooterRefresh() {
        sendActionsForControlEvents(.ValueChanged)
        isValueChanged = true
    }
    
    func endFooterRefresh() {}
    
    override func layoutSubviews() { super.layoutSubviews() }
    deinit {
        if let superview = superview as? UIScrollView {
            superview.removeObserver(self, forKeyPath: GHREFRESH_ContentOffsetKey)
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let superview = superview as? UIScrollView {
            superview.removeObserver(self, forKeyPath: GHREFRESH_ContentOffsetKey)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview as? UIScrollView {
            superview.addObserver(self, forKeyPath: GHREFRESH_ContentOffsetKey, options: [.New, .Old], context: nil)
        }
    }
    
    var expandedFooterHeight: CGFloat { return GHREFRESH_MaxFooterHeight }
    
    // MARK: - if superview`frame is changing this will be invoked in time
    func changeRefreshingFooterFrame(currentOffset:CGPoint,superview:UIScrollView) {
        footerChangingInset = true
        let maxheight = superview.contentSize.height
        let height = superview.height
        if maxheight <= height - self.expandedFooterHeight { return }
        frame = CGRectMake(0,  maxheight, superview.width, expandedFooterHeight)
        let minheight = maxheight - height
        var contentInset = superview.contentInset
        contentInset.bottom = minheight + self.expandedFooterHeight
        superview.contentInset = contentInset
        footerChangingInset = false
        // +1 防止闪屏
        superview.setContentOffset(CGPoint(x: 0, y: currentOffset.y + 1), animated: false)
        superview.setContentOffset(CGPoint(x: 0, y: contentInset.bottom), animated: !self.isSuperviewHeightAlwaysChanging)
    }
}

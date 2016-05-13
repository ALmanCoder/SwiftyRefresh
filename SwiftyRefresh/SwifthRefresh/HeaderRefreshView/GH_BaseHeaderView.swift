//
//  GH_BaseHeaderView.swift
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

//  HeaderView 工厂

import UIKit

class GH_BaseHeaderView: UIControl {
    
    var headerContentInsets : UIEdgeInsets!
    var headerForbidsOffsetChanges = false
    var headerForbidsInsetChanges = false
    var headerChangingInset = false
    var isheaderRefreshing = false
    var isheaderRefreshAnimated = false
    var topAnchorDownToUp = false
    
    var animationImages : [UIImage] = []
    
    var isSuperviewHeightAlwaysChanging = false
    var isValueChanged = false
    
    // MARK: - 消息提示容器
    lazy var messageBgView : UIView = {
        let width = UIScreen.mainScreen().bounds.width
        let frame = CGRectMake(width / 3, 0, width / 3, GHREFRESH_MImgHeight)
        let messageBgView = UIView(frame:frame)
        messageBgView.backgroundColor = UIColor.clearColor()
        return messageBgView
    }()
    
    // MARK: - 消息提示
    lazy var messageLabel : UILabel = {
        let frame = CGRectMake(0, 0, self.messageBgView.width, GHREFRESH_MImgHeight * 0.5)
        let messageLabel = UILabel(frame:frame)
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.textAlignment = .Center
        messageLabel.text = GHREFRESH_headerPrepareRefresh
        return messageLabel
    }()
    
    // MARK: - 最近更新时间
    lazy var updateLabel : UILabel = {
        let halfHeight = GHREFRESH_MImgHeight * 0.5
        let frame = CGRectMake(0, halfHeight, self.messageBgView.width, halfHeight)
        let updateLabel = UILabel(frame:frame)
        updateLabel.backgroundColor = UIColor.clearColor()
        updateLabel.font = UIFont.systemFontOfSize(14)
        updateLabel.adjustsFontSizeToFitWidth = true
        updateLabel.textAlignment = .Center
        return updateLabel
    }()
    
    // MARK: - 箭头控件
    lazy var anchorImgView : UIImageView = {
        let anchorImgView = UIImageView()
        anchorImgView.backgroundColor = UIColor.clearColor()
        return anchorImgView
    }()

    // MARK: - 菊花
    lazy var indicatorView : UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()

    // MARK: - 图片组动画
    lazy var animationImgView : UIImageView = {
        let animationImgView = UIImageView()
        animationImgView.backgroundColor = UIColor.clearColor()
        return animationImgView
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
    
    // MARK: - addTarget
    internal func addHeaderRefreshView(superview:AnyObject, target:AnyObject ,action:Selector) {
        if let superview = superview as? UIScrollView {
            removeTarget(target, action: action, forControlEvents: .ValueChanged)
            self.removeFromSuperview()
            addTarget(target, action: action, forControlEvents: .ValueChanged)
            superview.addSubview(self)
            superview.sendSubviewToBack(self)
        }
    }
    
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
    
    // 子类重写beginHeaderRefresh
    internal func beginHeaderRefresh() {
        sendActionsForControlEvents(.ValueChanged)
        isValueChanged = true
    }
    // 子类重写endHeaderRefresh
    internal func endHeaderRefresh() {}

}

//
//  GH_RefreshConfig.swift
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
import Foundation

// MARK: - sharedInstance
let AutoFooterRefreshView = GHAutoFooterRefreshView.sharedInstance()
let ImagesHeaderRefreshView = GHImagesHeaderRefreshView.sharedInstance()

let ArrowHeaderRefreshView = GHArrowHeaderRefreshView.sharedInstance()
let ArrowFooterRefreshView = GHArrowFooterRefreshView.sharedInstance()

let GifNoticeHeaderRefreshView = GHGifNoticeHeaderRefreshView.sharedInstance()
let GifNoticeFooterRefreshView = GHGifNoticeFooterRefreshView.sharedInstance()

let GifNormalHeaderRefreshView = GHGifNormalHeaderRefreshView.sharedInstance()
let GifNormalFooterRefreshView = GHGifNormalFooterRefreshView.sharedInstance()


// MARK: - config
public enum GHFooterRefreshDataType : Int {
    case HaveMoreData   // 有更多数据
    case NoMoreData     // 无更多数据
}

let GHREFRESH_ContentOffsetKey                 = "contentOffset"
let GHREFRESH_ContentSizeKey                   = "contentSize"

let GHREFRESH_MaxHeaderHeight                  = CGFloat(60)        // 要考虑状态栏的影响
let GHREFRESH_MaxFooterHeight                  = CGFloat(50)

let GHREFRESH_MaxFrameCount                    = 6                  // 最大帧数(可根据自己的图片资源调整)
let GHREFRESH_MaxImgsCount                     = 60                 // 最大动画组图片数
let GHREFRESH_MLabelHeight                     = CGFloat(20)
let GHREFRESH_MImgWidth                        = CGFloat(15)
let GHREFRESH_MImgHeight                       = CGFloat(40)

// MARK: - 提示语
let GHREFRESH_headerPrepareRefresh             = "下拉可以刷新"
let GHREFRESH_headerWillRefresh                = "松开立即刷新"
let GHREFRESH_headerRefreshIng                 = "正在刷新..."
let GHREFRESH_headerRefreshEnd                 = "刷新结束"

let GHREFRESH_footerPrepareRefresh             = "上拉加载更多"
let GHREFRESH_footerWillRefresh                = "松开立即加载"
let GHREFRESH_footerRefreshIng                 = "正在加载..."
let GHREFRESH_footerRefreshEnd                 = "加载完成"
let GHREFRESH_footerNoMoreData                 = "无更多数据"

// MARK: - animation
let GHREFRESH_TransformAngle                   = CGFloat(0.000001 - M_PI)
let GHREFRESH_AnchorDuration                   = NSTimeInterval(0.3)

// MARK: - NSUserDefaults
let GH_UserDefaults = NSUserDefaults.standardUserDefaults()

// MARK: - 成屏宽比系数，依375为基准
func GH_ScaleScreen(s:CGFloat) -> CGFloat{
    return (s) * UIScreen.mainScreen().bounds.width / 375.0
}

// MARK: - navHeight (防止提示语状态已经改变，与是否真正刷新保持一致)
func navBarHeight() -> CGFloat{
    return UIApplication.sharedApplication().statusBarFrame.height
}

// MARK: - load image source from mainBundle
func loadBoundleData(name:String,type:String) -> NSData {
    return NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(name, ofType: type)!)!
}

// MARK: - load gif source from Refresh.bundle
func loadGifFromRefreshBoundle(name:String,type:String) -> NSData {
    let bundlePath = NSBundle.mainBundle().pathForResource("Refresh", ofType: "bundle")! as NSString
    let filePath = bundlePath.stringByAppendingPathComponent(name + "." + type)
    return NSData(contentsOfFile: filePath)!
}

// MARK: - load png source from Refresh.bundle, you can also use loadGifFromRefreshBoundle instead
func getImageFromRefreshBundle(imageName:String) -> String {
    return ("Refresh.bundle" as NSString).stringByAppendingPathComponent(imageName)
}

// MARK: - AfterClosure
typealias AfterClosure = () -> ()
func dispatchAfter(time:CGFloat,afterClosure:AfterClosure) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue())
    { () -> Void in afterClosure() }
}

// MARK: - bgColor
func bgColor() -> UIColor {
    return RGB(240,240,240)
}

// MARK: - TestColor
func TestColor () -> UIColor {
    return RGB(CGFloat(arc4random()%255), CGFloat(arc4random()%255), CGFloat(arc4random()%255))
}

// MARK: - RGB
func RGB(r : CGFloat, _ g:CGFloat, _ b:CGFloat) -> UIColor {
    return RGBA(r, g, b, 1.0)
}

// MARK: - RGBA
func RGBA (r : CGFloat, _ g : CGFloat, _ b : CGFloat, _ a : CGFloat) -> UIColor {
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}

// MARK: - lastUpdateTime
func saveTime(){
    GH_UserDefaults.setValue(NSDate(), forKey: "LastUpdateTimeKey")
    GH_UserDefaults.synchronize()
}

func getLastUpdateTime() -> String{
    if let lastUpdatedTime : NSDate = GH_UserDefaults.valueForKey("LastUpdateTimeKey") as? NSDate  {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags : NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute]
        let dcp1 = calendar.components(unitFlags, fromDate: lastUpdatedTime)
        let dcp2 = calendar.components(unitFlags, fromDate: NSDate())
        
        let formatter = NSDateFormatter()
        if (dcp1.day == dcp2.day) {
            formatter.dateFormat = "今天 HH:mm"
        } else if (dcp1.year == dcp2.year) {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        return "最后更新：" + formatter.stringFromDate(lastUpdatedTime)
    } else {
        return "最后更新：无记录"
    }
}


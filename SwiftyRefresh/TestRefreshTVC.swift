//
//  TestTableViewController.swift
//  SwiftyRefresh
//
//  Created by guanghuiwu on 16/5/13.
//  Copyright © 2016年 ALmanCoder. All rights reserved.
//  Demo

import UIKit

class TestTableViewController: UITableViewController {
    
    let refreshControllerTitle = ["GifNormalTableVC", "GifWithTitleTableVC", "ArrowTableVC", "ImagesTableVC","CollectionVC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refreshControllerTitle.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
        cell.textLabel?.text = refreshControllerTitle[indexPath.row]
        cell.backgroundColor = TestColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let typeName = refreshControllerTitle[indexPath.row]
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let testVC = mainStoryBoard.instantiateViewControllerWithIdentifier(typeName)
        navigationController?.pushViewController(testVC, animated: true)
    }
}


class GifNormalTableVC: UITableViewController {
    var count = 16
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GifNormalHeaderRefreshView.addHeaderRefreshView(tableView,target:self, action: #selector(headerRefresh))
        GifNormalHeaderRefreshView.gifImageName = "paobu"
        GifNormalHeaderRefreshView.isSuperviewHeightAlwaysChanging = true
        GifNormalHeaderRefreshView.beginHeaderRefresh()
        
        GifNormalFooterRefreshView.addFooterRefreshView(tableView,target:self, action: #selector(footerRefresh))
        GifNormalFooterRefreshView.gifImageName = "paobu"
    }
    
    func headerRefresh() {
        dispatchAfter(1) {
            if GifNormalHeaderRefreshView.isValueChanged {
                GifNormalHeaderRefreshView.isValueChanged = false
                self.count = 16
                GifNormalFooterRefreshView.dataType = .HaveMoreData
                self.tableView.reloadData()
                GifNormalHeaderRefreshView.endHeaderRefresh()
            }
        }
    }
    
    func footerRefresh() {
        dispatchAfter(1) {
            if GifNormalFooterRefreshView.isValueChanged {
                GifNormalFooterRefreshView.isValueChanged = false
                if self.count == 26 { self.count += 4 }
                else { self.count += 10 }
                if self.count >= 36 {
                    self.count = 36
                    self.tableView.reloadData()
                    GifNormalFooterRefreshView.dataType = .NoMoreData
                } else {
                    self.tableView.reloadData()
                    GifNormalFooterRefreshView.dataType = .HaveMoreData
                }
                GifNormalFooterRefreshView.endFooterRefresh()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // return 60
        // isSuperviewHeightAlwaysChanging = true 
        // 这样返回高度有点bug不知道怎么处理
        return 44 + CGFloat(arc4random() % 100)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
        cell.textLabel?.text = "row --- \(indexPath.row)"
        cell.backgroundColor = TestColor()
        return cell
    }
}


class GifWithTitleTableVC: UITableViewController {
    var count = 16
    override func viewDidLoad() {
        super.viewDidLoad()
        GifNoticeHeaderRefreshView.addHeaderRefreshView(tableView,target:self, action: #selector(headerRefresh))
        GifNoticeHeaderRefreshView.gifImageName = "paobu"
        GifNoticeHeaderRefreshView.beginHeaderRefresh()
        
        GifNoticeFooterRefreshView.addFooterRefreshView(tableView,target:self, action: #selector(footerRefresh))
        GifNoticeFooterRefreshView.gifImageName = "paobu"

    }
    
    func headerRefresh() {
        dispatchAfter(1) {
            if GifNoticeHeaderRefreshView.isValueChanged {
                GifNoticeHeaderRefreshView.isValueChanged = false
                self.count = 16
                GifNoticeFooterRefreshView.dataType = .HaveMoreData
                self.tableView.reloadData()
                GifNoticeHeaderRefreshView.endHeaderRefresh()
            }
        }
    }
    
    func footerRefresh() {
        dispatchAfter(1) {
            if GifNoticeFooterRefreshView.isValueChanged {
                GifNoticeFooterRefreshView.isValueChanged = false
                if self.count == 26 { self.count += 4 }
                else { self.count += 10 }
                if self.count >= 36 {
                    self.count = 36
                    self.tableView.reloadData()
                    GifNoticeFooterRefreshView.dataType = .NoMoreData
                } else {
                    self.tableView.reloadData()
                    GifNoticeFooterRefreshView.dataType = .HaveMoreData
                }
                GifNoticeFooterRefreshView.endFooterRefresh()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
        cell.textLabel?.text = "row --- \(indexPath.row)"
        cell.backgroundColor = TestColor()
        return cell
    }
}


class ArrowTableVC: UITableViewController {
    var count = 16
    override func viewDidLoad() {
        super.viewDidLoad()
        ArrowHeaderRefreshView.addHeaderRefreshView(tableView,target:self, action: #selector(headerRefresh))
        ArrowHeaderRefreshView.beginHeaderRefresh()
        
        ArrowFooterRefreshView.addFooterRefreshView(tableView,target:self, action: #selector(footerRefresh))
    }
    
    func headerRefresh() {
        dispatchAfter(1) {
            if ArrowHeaderRefreshView.isValueChanged {
                ArrowHeaderRefreshView.isValueChanged = false
                self.count = 16
                ArrowFooterRefreshView.dataType = .HaveMoreData
                self.tableView.reloadData()
                ArrowHeaderRefreshView.endHeaderRefresh()
            }
        }
    }
    
    func footerRefresh() {
        dispatchAfter(1) {
            if ArrowFooterRefreshView.isValueChanged {
                ArrowFooterRefreshView.isValueChanged = false
                if self.count == 26 { self.count += 4 }
                else { self.count += 10 }
                if self.count >= 36 {
                    self.count = 36
                    self.tableView.reloadData()
                    ArrowFooterRefreshView.dataType = .NoMoreData
                } else {
                    self.tableView.reloadData()
                    ArrowFooterRefreshView.dataType = .HaveMoreData
                }
                ArrowFooterRefreshView.endFooterRefresh()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
        cell.textLabel?.text = "row --- \(indexPath.row)"
        cell.backgroundColor = TestColor()
        return cell
    }
}

class ImagesTableVC: UITableViewController {
    var count = 16
    override func viewDidLoad() {
        super.viewDidLoad()
        ImagesHeaderRefreshView.addHeaderRefreshView(tableView,target:self, action: #selector(headerRefresh))
        ImagesHeaderRefreshView.beginHeaderRefresh()
        
        AutoFooterRefreshView.addFooterRefreshView(tableView,target:self, action: #selector(footerRefresh))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ImagesHeaderRefreshView.endHeaderRefresh()
        AutoFooterRefreshView.endFooterRefresh()
    }
    
    func headerRefresh() {
        dispatchAfter(1) {
            if ImagesHeaderRefreshView.isValueChanged {
                ImagesHeaderRefreshView.isValueChanged = false
                self.count = 16
                AutoFooterRefreshView.dataType = .HaveMoreData
                self.tableView.reloadData()
                ImagesHeaderRefreshView.endHeaderRefresh()
            }
        }
    }
    
    func footerRefresh() {
        dispatchAfter(1) {
            if AutoFooterRefreshView.isValueChanged {
                AutoFooterRefreshView.isValueChanged = false
                if self.count == 26 { self.count += 4 }
                else { self.count += 10 }
                if self.count >= 36 {
                    self.count = 36
                    self.tableView.reloadData()
                    AutoFooterRefreshView.dataType = .NoMoreData
                } else {
                    self.tableView.reloadData()
                    AutoFooterRefreshView.dataType = .HaveMoreData
                }
                AutoFooterRefreshView.endFooterRefresh()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
        cell.textLabel?.text = "row --- \(indexPath.row)"
        cell.backgroundColor = TestColor()
        return cell
    }
}

class CollectionVC: UICollectionViewController {
    var count = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        collectionView?.backgroundColor = UIColor.whiteColor()
        ImagesHeaderRefreshView.addHeaderRefreshView(collectionView!,target:self, action: #selector(headerRefresh))
        ImagesHeaderRefreshView.beginHeaderRefresh()
        
        AutoFooterRefreshView.addFooterRefreshView(collectionView!,target:self, action: #selector(footerRefresh))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ImagesHeaderRefreshView.endHeaderRefresh()
        AutoFooterRefreshView.endFooterRefresh()
    }
    
    func headerRefresh() {
        dispatchAfter(1) {
            if ImagesHeaderRefreshView.isValueChanged {
                ImagesHeaderRefreshView.isValueChanged = false
                self.count = 100
                AutoFooterRefreshView.dataType = .HaveMoreData
                self.collectionView!.reloadData()
                ImagesHeaderRefreshView.endHeaderRefresh()
            }
        }
    }
    
    func footerRefresh() {
        dispatchAfter(1) {
            if AutoFooterRefreshView.isValueChanged {
                AutoFooterRefreshView.isValueChanged = false
                if self.count == 110 { self.count += 4 }
                else { self.count += 30 }
                if self.count >= 160 {
                    self.count = 160
                    self.collectionView!.reloadData()
                    AutoFooterRefreshView.dataType = .NoMoreData
                } else {
                    self.collectionView!.reloadData()
                    AutoFooterRefreshView.dataType = .HaveMoreData
                }
                AutoFooterRefreshView.endFooterRefresh()
            }
        }
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCellId", forIndexPath: indexPath)
        collectionViewCell.backgroundColor = TestColor()
        return collectionViewCell
    }

    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 60
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")! as UITableViewCell
//        cell.textLabel?.text = "row --- \(indexPath.row)"
//        cell.backgroundColor = TestColor()
//        return cell
//    }
}

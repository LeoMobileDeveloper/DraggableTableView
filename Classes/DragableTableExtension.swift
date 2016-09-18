//
//  DragableTableExtension.swift
//  DragableTableExtension
//
//  Created by huangwenchen on 16/9/8.
//  Copyright © 2016年 Leo. All rights reserved.

import Foundation
import ObjectiveC
import UIKit


@objc public protocol DragableTableDelegate:AnyObject{
    
    /**
     A cell is moved from FromIndexPath to toIndexPath,you need to adjust your model here
     - parameter tableView: tableview
     - parameter fromIndexPath: from indexPath
     - parameter toIndexPath: toIndexPath
     - returns: void
     */
    func tableView(tableView:UITableView,dragCellFrom fromIndexPath:NSIndexPath,toIndexPath:NSIndexPath)
    /**
     Weather a cell is dragable
     
     - parameter tableView: tableView
     - parameter indexPath: target indexPath
     - parameter point:     point that in tableview Cell
     
     - returns: dragable or not
     */
    optional func tableView(tableView: UITableView,canDragCellFrom indexPath: NSIndexPath, withTouchPoint point:CGPoint) -> Bool
    
    /**
     Weahter a cell is sticky during dragging
     
     - parameter tableView: tableview
     - parameter indexPath: toIndex
     
     - returns: sticky or not
     */
    optional func tableView(tableView: UITableView,canDragCellTo indexPath: NSIndexPath) -> Bool
    
    /**
     Called when the screenshot imageView center change
     
     - parameter tableView: tableView
     - parameter imageView: screenshot
     */
    optional func tableView(tableView: UITableView,dragableImageView imageView: UIImageView)
}

/// A class to hold propertys
private class DragableHelper:NSObject,UIGestureRecognizerDelegate{
    
    weak var draggingCell:UITableViewCell?
    let displayLink: _DisplayLink
    let gesture: UILongPressGestureRecognizer
    let floatImageView: UIImageView
    
    weak var attachTableView:UITableView?
    var scrollSpeed: CGFloat = 0.0
    init(tableView: UITableView, displayLink:_DisplayLink, gesture:UILongPressGestureRecognizer,floatImageView:UIImageView) {
        self.displayLink = displayLink
        self.gesture = gesture
        self.floatImageView = floatImageView
        self.attachTableView = tableView
        super.init()
        self.gesture.delegate = self
    }
    @objc func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let attachTableView = attachTableView else{
            return false
        }
        return attachTableView.lh_gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
public extension UITableView{
    private struct OBJC_Key{
        static var dragableDelegateKey = 0
        static var dragableHelperKey = 1
        static var dragableKey = 2
        static var dragablePaddingTopKey = 3
    }
    // MARK: - Associated propertys -
    public var dragableDelegate:DragableTableDelegate?{
        get{
            return objc_getAssociatedObject(self, &OBJC_Key.dragableDelegateKey) as? DragableTableDelegate
        }
        set{
            objc_setAssociatedObject(self, &OBJC_Key.dragableDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    public var dragable:Bool{
        get{
            let number = objc_getAssociatedObject(self, &OBJC_Key.dragableKey) as! NSNumber
            return number.boolValue
        }
        set{
            if newValue.boolValue {
                setupDragable()
            }else{
                cleanDragable()
            }
            let number = NSNumber(bool: newValue)
            objc_setAssociatedObject(self, &OBJC_Key.dragableDelegateKey, number, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    public var paddingTop:CGFloat{
        get{
            let number = objc_getAssociatedObject(self, &OBJC_Key.dragablePaddingTopKey) as? NSNumber
            guard let num = number else{
                return 0.0;
            }
            return CGFloat(num.floatValue)
        }
        set{
            let number = NSNumber(float: Float(newValue))
            objc_setAssociatedObject(self, &OBJC_Key.dragablePaddingTopKey, number, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    private var dragableHelper:DragableHelper?{
        get{
            return objc_getAssociatedObject(self, &OBJC_Key.dragableHelperKey) as? DragableHelper
        }
        set{
            objc_setAssociatedObject(self, &OBJC_Key.dragableHelperKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    // MARK: - Private set up -
    private func setupDragable(){
        if dragableHelper != nil{
            cleanDragable()
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(UITableView.handleLongPress))
        addGestureRecognizer(longPressGesture)
        let displayLink = _DisplayLink{ [unowned self] in
            guard let dragableHelper = self.dragableHelper else{
                return
            }
            self.contentOffset.y = min(max(0.0, self.contentOffset.y + dragableHelper.scrollSpeed),self.contentSize.height - self.frame.height)
            self.adjusFloatImageViewCenterY(dragableHelper.gesture.locationInView(self).y)
        }
        
        let imageView = UIImageView()
        let helper = DragableHelper(tableView:self,displayLink: displayLink, gesture: longPressGesture, floatImageView: imageView)
        dragableHelper = helper
    }
    private func cleanDragable(){
        guard let helper = dragableHelper else{
            return
        }
        removeGestureRecognizer(helper.gesture)
        dragableHelper = nil
    }
    
    // MARK: - Handle gesture and display link-
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer){
        assert(dragableDelegate != nil, "You must set delegate")
        guard let dragableHelper = dragableHelper else{
            return
        }
        let location = gesture.locationInView(self)
        switch gesture.state {
        case .Began:
            guard let currentIndexPath = indexPathForRowAtPoint(location),let currentCell = cellForRowAtIndexPath(currentIndexPath)else{
                return
            }
            if let selectedRow = indexPathForSelectedRow{
                deselectRowAtIndexPath(selectedRow, animated: false)
            }
            allowsSelection = false
            currentCell.highlighted = false
            dragableHelper.draggingCell = currentCell
            //Configure imageview
            let screenShot = currentCell.lh_screenShot()
            dragableHelper.floatImageView.image = screenShot
            
            dragableHelper.floatImageView.frame = currentCell.bounds
            dragableHelper.floatImageView.center = currentCell.center
            self.dragableDelegate?.tableView?(self, dragableImageView: dragableHelper.floatImageView)
            dragableHelper.floatImageView.layer.shadowRadius = 5.0
            dragableHelper.floatImageView.layer.shadowOpacity = 0.2
            dragableHelper.floatImageView.layer.shadowOffset = CGSizeZero
            dragableHelper.floatImageView.layer.shadowPath = UIBezierPath(rect: dragableHelper.floatImageView.bounds).CGPath
            addSubview(dragableHelper.floatImageView)
            
            UIView.animateWithDuration(0.2, animations: {
                dragableHelper.floatImageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dragableHelper.floatImageView.alpha = 0.5
            })
            currentCell.hidden =  true
        case .Changed:
            adjusFloatImageViewCenterY(location.y)
            dragableHelper.scrollSpeed = 0.0
            //Refer from here https://github.com/okla/QuickRearrangeTableView/blob/master/QuickRearrangeTableView.swift
            if contentSize.height > frame.height {
                let halfCellHeight = dragableHelper.floatImageView.frame.size.height / 2.0
                let cellCenterToTop = dragableHelper.floatImageView.center.y - bounds.origin.y - paddingTop
                self.dragableDelegate?.tableView?(self, dragableImageView: dragableHelper.floatImageView)
                if cellCenterToTop < halfCellHeight {
                    dragableHelper.scrollSpeed = 5.0*(cellCenterToTop/halfCellHeight - 1.1)
                }
                else if cellCenterToTop > frame.height - halfCellHeight {
                    dragableHelper.scrollSpeed = 5.0*((cellCenterToTop - frame.height)/halfCellHeight + 1.1)
                }
                dragableHelper.displayLink.paused = (dragableHelper.scrollSpeed == 0)
            }
        default:
            allowsSelection = true
            dragableHelper.displayLink.paused = true
            UIView.animateWithDuration(0.2,
                                       animations: {
                                        dragableHelper.floatImageView.transform = CGAffineTransformIdentity
                                        dragableHelper.floatImageView.alpha = 1.0
                                        dragableHelper.floatImageView.frame = dragableHelper.draggingCell!.frame
                },
                                       completion: { (completed) in
                                        dragableHelper.floatImageView.removeFromSuperview()
                                        dragableHelper.draggingCell?.hidden = false
                                        dragableHelper.draggingCell = nil
            })
        }
    }
    func lh_gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.locationInView(self)
        guard let currentIndexPath = indexPathForRowAtPoint(location),let currentCell = cellForRowAtIndexPath(currentIndexPath) else{
            return false
        }
        let pointInCell = convertPoint(location, toView: currentCell)
        guard let canDrag = dragableDelegate?.tableView?(self, canDragCellFrom: currentIndexPath, withTouchPoint: pointInCell) else{
            return true
        }
        return canDrag
    }
    
    // MARK: - Private method -
    func adjusFloatImageViewCenterY(newY:CGFloat){
        guard let floatImageView = dragableHelper?.floatImageView else{
            return
        }
        floatImageView.center.y = min(max(newY, bounds.origin.y), bounds.origin.y + bounds.height)
        self.dragableDelegate?.tableView?(self, dragableImageView: floatImageView)
        adjustCellOrderIfNecessary()
    }
    
    func adjustCellOrderIfNecessary(){
        guard let dragableDelegate = dragableDelegate,floatImageView = dragableHelper?.floatImageView,toIndexPath = indexPathForRowAtPoint(floatImageView.center) else{
            return
        }
        guard let draggingCell = dragableHelper?.draggingCell,dragingIndexPath = indexPathForCell(draggingCell) else{
            return
        }
        guard dragingIndexPath.compare(toIndexPath) != NSComparisonResult.OrderedSame else{
            return
        }
        if let canDragTo = dragableDelegate.tableView?(self, canDragCellTo: toIndexPath){
            if !canDragTo {
                
                return
            }
        }
        draggingCell.hidden = true
        beginUpdates()
        dragableDelegate.tableView(self, dragCellFrom: dragingIndexPath, toIndexPath: toIndexPath)
        moveRowAtIndexPath(dragingIndexPath, toIndexPath: toIndexPath)
        endUpdates()
    }
}
private class _DisplayLink{
    var paused:Bool{
        get{
            return _link.paused
        }
        set{
            _link.paused = newValue
        }
    }
    private init (_ callback: Void -> Void) {
        _callback = callback
        _link = CADisplayLink(target: _DisplayTarget(self), selector: #selector(_DisplayTarget._callback))
        _link.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        _link.paused = true
    }
    
    private let _callback: Void -> Void
    
    private var _link: CADisplayLink!
    
    deinit {
        _link.invalidate()
    }
}

/// Retained by CADisplayLink.
private class _DisplayTarget {
    
    init (_ link: _DisplayLink) {
        _link = link
    }
    
    weak var _link: _DisplayLink!
    
    @objc func _callback () {
        _link?._callback()
    }
}
private extension UIView{
    /**
     Get the screenShot of a UIView
     
     - returns: Image of self
     */
    func lh_screenShot()->UIImage?{
        let mask = layer.mask
        layer.mask = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        layer.mask = mask
        return image
    }
}
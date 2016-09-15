 
# DraggableTableView

 [![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
                                                                                                                                                 )](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
             )](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
            )](http://mit-license.org)

DraggableTableView is a `UITableView` extesntion to make tableview draggable by long press. 

## Features
- [x] Default


<img src="https://github.com/LeoMobileDeveloper/DraggableTableView/blob/master/ScreenShot/1.gif?raw=true" width="200">


- [x] Special cell fixed 

<img src="https://github.com/LeoMobileDeveloper/DraggableTableView/blob/master/ScreenShot/2.gif?raw=true" width="200">

- [x] Only subview in cell is dragable

<img src="https://github.com/LeoMobileDeveloper/DraggableTableView/blob/master/ScreenShot/3.gif?raw=true" width="200">

## Require

- iOS 8
- Swift 2


## Install

CocoaPod(Coming soon)

```
pod "DraggableTableView"
```


## Useage

Enable dragable and set delegate

```
self.tableView.dragable = true
self.tableView.dragableDelegate = self
```

In delegate method,

``` 
 //Required, manage data source here
 func tableView(tableView: UITableView, dragCellFrom fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) 
 
 //Optional, decide if a cell can be draged from
 func tableView(tableView: UITableView, canDragCellTo indexPath: NSIndexPath) -> Bool 
 
 //Optional, decide if a cell can be draged to
 func tableView(tableView: UITableView, canDragCellFrom indexPath: NSIndexPath, withTouchPoint point: CGPoint) 
```

## Author

Leo, leomobiledeveloper@gmail.com

## License

DraggableTableView is available under the MIT license. See the LICENSE file for more info.


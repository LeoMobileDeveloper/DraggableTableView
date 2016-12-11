//
//  DefaultController.swift
//  DragableTableExtension
//
//  Created by huangwenchen on 16/9/12.
//  Copyright © 2016年 Leo. All rights reserved.
//

import UIKit

class DefaultController: UITableViewController,DragableTableDelegate{

    var dataArray:NSMutableArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        //Set up dragable
        self.tableView.dragable = true
        self.tableView.dragableDelegate = self
    }
    // MARK: - DragableTableDelegate
    func tableView(_ tableView: UITableView, dragCellFrom fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        dataArray.exchangeObject(at: fromIndexPath.row, withObjectAt: toIndexPath.row)
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell
        cell?.customLabel?.text = "\(dataArray[indexPath.row])"
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }


}

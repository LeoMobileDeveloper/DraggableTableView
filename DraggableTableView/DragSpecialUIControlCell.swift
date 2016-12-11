//
//  DragSpecialUIControlCell.swift
//  DragableTableExtension
//
//  Created by huangwenchen on 16/9/12.
//  Copyright © 2016年 Leo. All rights reserved.
//

import UIKit

class DragSpecialUIControlCell: UITableViewCell {
    func longPressValid(_ point:CGPoint)->Bool{
        return editImageView.frame.contains(point)
    }
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var customLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

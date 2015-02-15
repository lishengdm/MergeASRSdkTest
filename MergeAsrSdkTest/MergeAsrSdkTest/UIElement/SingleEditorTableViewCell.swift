//
//  SingleEditorTableViewCell.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/6.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

class SingleEditorTableViewCell: UITableViewCell {

    @IBOutlet var textViewTestNumber: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

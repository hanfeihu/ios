//
//  DeviceCell.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
    }

    
    
}

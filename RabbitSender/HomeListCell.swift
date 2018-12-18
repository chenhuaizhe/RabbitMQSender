//
//  HomeListCell.swift
//  RabbitSender
//
//  Created by ChenYuan's Macbook Air on 2018/12/18.
//  Copyright © 2018 ChenYuan's Macbook. All rights reserved.
//

import UIKit

typealias sendValueClosure = () -> Void

class HomeListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var myClosure:sendValueClosure?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func sendButtonClicked(_ sender: Any) {
        if self.myClosure != nil {
            self.myClosure!()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

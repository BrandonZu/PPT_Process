//
//  NotebookTableViewCell.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit

class NotebookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

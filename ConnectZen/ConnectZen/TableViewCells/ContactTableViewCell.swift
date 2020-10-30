//
//  ContactTableViewCell.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/29/20.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var ContactName: UILabel!
    @IBOutlet weak var ActionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

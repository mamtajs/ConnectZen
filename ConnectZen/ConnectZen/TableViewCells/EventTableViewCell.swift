//
//  EventTableViewCell.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/21/20.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    
    @IBOutlet weak var DayLabel: UILabel!
    //@IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var CellContentView: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        CellContentView.layer.cornerRadius = 10
        CellContentView.layer.backgroundColor = UIColor.systemGray6.cgColor
    }

    // Inside UITableViewCell subclass
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
    }
    
}

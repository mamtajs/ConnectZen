//
//  ContactsTableCell.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/8/20.
//

import UIKit

//Protocol declaration
protocol ContactsTableCellDelegate:class {
    func ContactsTableCell(cell:ContactsTableCell, didTappedThe button:UIButton?)
}

class ContactsTableCell: UITableViewCell {
    

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    //Delegate property as weak
    weak var cellDelegate:ContactsTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    @IBAction func deleteTapped(_ sender: Any) {
        cellDelegate?.ContactsTableCell(cell: self, didTappedThe: sender as?UIButton)
    }
}


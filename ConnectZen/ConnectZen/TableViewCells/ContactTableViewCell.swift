//
//  ContactTableViewCell.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/29/20.
//

import UIKit

//Protocol declaration
protocol ContactTableViewCellDelegate:class {
    func ContactTableViewCell(cell:ContactTableViewCell, didTappedThe button:UIButton?)
}

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var ContactName: UILabel!
    @IBOutlet weak var ActionButton: UIButton!
    var type:Bool = false
    //Delegate property as weak
    weak var cellDelegate:ContactTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
        
    @IBAction func ActionButtonPressed(_ sender: Any) {
        cellDelegate?.ContactTableViewCell(cell: self, didTappedThe: sender as?UIButton)
    }

    
}

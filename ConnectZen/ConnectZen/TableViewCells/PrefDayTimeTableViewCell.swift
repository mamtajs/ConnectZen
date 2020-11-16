//
//  PrefDayTimeTableViewCell.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/16/20.
//

import UIKit
//Protocol declaration
protocol PrefDayTimeTableViewCellDelegate:class {
    func PrefDayTimeTableViewCell(cell:PrefDayTimeTableViewCell, didTappedThe button:UIButton?)
}
class PrefDayTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var StartTimeLabel: UILabel!
    @IBOutlet weak var EndTimeLabel: UILabel!
    @IBOutlet weak var ActionButton: UIButton!
    
    //Delegate property as weak
    weak var cellDelegate:PrefDayTimeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func ActionButtonClicked(_ sender: Any) {
        cellDelegate?.PrefDayTimeTableViewCell(cell: self, didTappedThe: sender as?UIButton)
    }
    
}

//
//  PopUpViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit

class PopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func DismissPopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CloseClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UseAddressBookClicked(_ sender: Any) {
        
    }
    
    @IBAction func EnterContactManuallyClicked(_ sender: Any) {
    }
}

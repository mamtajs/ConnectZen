//
//  PopUpViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit
import Contacts

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

            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { (access, error) in
                print("Access: \(access)")
                if(access){ // contact Store access is granted by the user
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
      
                
            
        }
    }
    
    @IBAction func EnterContactManuallyClicked(_ sender: Any) {
    }
}

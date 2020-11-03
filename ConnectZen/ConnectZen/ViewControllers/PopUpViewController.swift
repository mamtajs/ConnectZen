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
                if(access){ // contact Store access is granted by the user
                    
                    // Navigate to the contacts view controller using root navigation controller
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsViewController
                    if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                   
                        navigationController.pushViewController(vc!, animated: true)
                        
                    }
                    
                    // dismiss the popup
                    self.dismiss(animated: true, completion: nil)
                    
                }
                else{
                    // TODO: Error state
                }
      
                
            
        }
    }
    
    @IBAction func EnterContactManuallyClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualContactsVC") as? ManualContactsViewController
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
       
            navigationController.pushViewController(vc!, animated: true)
            
        }
        // dismiss the popup
        self.dismiss(animated: true, completion: nil)
        
    }
}

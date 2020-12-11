//
//  PopUpViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit
import Contacts

class PopUpViewController: UIViewController {

    @IBOutlet weak var UseAddressBookButton: UIButton!
    @IBOutlet weak var EnterContactsManuallyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFilledButton(UseAddressBookButton, cornerRadius: largeCornerRadius)
        Utilities.styleFilledButton(EnterContactsManuallyButton, cornerRadius: largeCornerRadius)
    }
    
    
    @IBAction func UseAddressBookClicked(_ sender: Any) {

            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { (access, error) in
                if(access){ // contact Store access is granted by the user
                    //let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsViewController
                    //self.navigationController?.pushViewController(vc!, animated: true)
                    self.dismiss(animated: true, completion: nil)
                    // Navigate to the contacts view controller using root navigation controller
                    DispatchQueue.main.async{
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsViewController
                        self.navigationController?.pushViewController(vc!, animated: true)
                        /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsVC") as? ContactsViewController
                        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                       navigationController.pushViewController(vc!, animated: true)
                        }*/
                        
                        // dismiss the popup
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                
                }
                else{
                    // TODO: Error state
                }
      
                
            
        }
    }
    
    @IBAction func EnterContactManuallyClicked(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualContactsVC") as? ManualContactsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualContactsVC") as? ManualContactsViewController
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.pushViewController(vc!, animated: true)
        }*/
        // dismiss the popup
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //To hide navigation bar in a particular view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

//
//  ViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/9/20.
//

import UIKit

class LoginViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Hello World")
    }


    @IBAction func RegisterNewUser(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}


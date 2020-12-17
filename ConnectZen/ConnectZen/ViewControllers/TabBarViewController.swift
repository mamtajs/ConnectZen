//
//  TabBarViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 12/10/20.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        self.selectedIndex = 2
        
    }

}

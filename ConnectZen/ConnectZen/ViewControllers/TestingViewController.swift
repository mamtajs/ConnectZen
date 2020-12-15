//
//  TestingViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 12/12/20.
//

import UIKit

class TestingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
        //self.tabBarController?
        self.navigationController?.pushViewController(vc!, animated: true)
        // Do any additional setup after loading the view.
    }

}

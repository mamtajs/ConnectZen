//
//  HomeViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/8/20.
//

import UIKit
import Firebase
import FirebaseUI

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error Signing out- %@", signOutError)
        }
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginViewController
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func SettingButtonTapped(_ sender: Any) {
    }
    @IBAction func AnalyticsButtonDashboard(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalyticsVC") as? AnalyticsDashboardViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func CalendarButtonTapped(_ sender: Any) {
    }
    @IBAction func RewardsButtonTapped(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

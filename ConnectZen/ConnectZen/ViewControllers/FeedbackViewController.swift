//
//  FeedbackViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/5/20.
//

import UIKit
import Firebase

class FeedbackViewController: UIViewController {

    let db = Firestore.firestore()
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var feebackText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
        // Do any additional setup after loading the view.
        Utilities.styleFilledButton(submitButton, cornerRadius: xLargeCornerRadius)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*let navigationController2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "settingNavigationControllerVC") as? UINavigationController
        navigationController2?.setNavigationBarHidden(true, animated: animated)*/
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "Feedback"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Feedback": feebackText.text!], merge: true)
        navigateToTabBar()
        //showToast(controller: self, message: "Thank you for your feedback.", seconds: 2, colorBackground: .systemGreen, title: "Success")
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

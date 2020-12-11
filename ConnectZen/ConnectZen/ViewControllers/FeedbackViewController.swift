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
    
    @IBAction func submitTapped(_ sender: Any) {
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Feedback": feebackText.text!], merge: true)
        
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

//
//  ResetPasswordViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/9/20.
//

import UIKit
import Firebase
import FirebaseUI

class ResetPasswordViewController: UIViewController, FUIAuthDelegate {

    var authUI: FUIAuth?
    @IBOutlet weak var emailAddressText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func resetPassword(){
        let emailAddress = emailAddressText.text!
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { (error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .userNotFound:
                print("user not found")
            case .invalidEmail:
                print("invalid email")
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            print("Reset password email has been successfully sent")
            NotificationBanner.show("Reset password email has been sent to your given email address.")
          }
        }
    }
    
    @IBAction func sendEmailTapped(_ sender: Any) {
        self.resetPassword()
        self.navigationController?.popToRootViewController(animated: true)
    }

}

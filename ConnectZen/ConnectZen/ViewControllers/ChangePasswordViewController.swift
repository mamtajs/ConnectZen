//
//  ChangePasswordViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/9/20.
//

import UIKit
import FirebaseUI

class ChangePasswordViewController: UIViewController {

    var authUI: FUIAuth?
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    
    @IBOutlet weak var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
        // Do any additional setup after loading the view.
        Utilities.styleFilledButton(changePasswordButton, cornerRadius: xLargeCornerRadius)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*let navigationController2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "settingNavigationControllerVC") as? UINavigationController
        navigationController2?.setNavigationBarHidden(true, animated: animated)*/
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "Change Password"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func reAuthenticateUser(){
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController
        vc?.changePassFlag = 1
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
        credential = EmailAuthProvider.credential(withEmail: userEmail, password: userPassword)
        user?.reauthenticate(with: credential, completion: { (result, err) in
            if err != nil{
                print("error re-authenticating the user")
            }else{
                print("Successful reauthentication done")
                userEmail = ""
                userPassword = ""
            }
        })
    }
    func changePassword(){
        let password = passwordText.text!
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .userDisabled:
                print("The user account has been disabled by an administrator.")
            case .weakPassword:
                print("The password must be 6 characters long or more.")
            case .requiresRecentLogin:
                self.reAuthenticateUser()
                self.changePassword()
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            NotificationBanner.successShow("Password updated successfully")
            /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            self.navigationController?.pushViewController(vc!, animated: true)*/
            navigateToTabBar()
            print("User signs up successfully")
          }
        })
        
    }
    func validateFields() -> String?{
        let cleanedPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedConfirmPassword = confirmPasswordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedPassword != cleanedConfirmPassword{
            return "Passwords do not match."
        }
        return nil
    }
    
    @IBAction func changePasswordTapped(_ sender: Any) {
        let error = validateFields()
        if error != nil{
            NotificationBanner.showFailure(error!)
        }else{
            self.changePassword()
        }
        
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

//
//  ViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/9/20.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate, UIApplicationDelegate{

    var authUI: FUIAuth?
    
    @IBOutlet weak var emailIDText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var changePassFlag = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailIDText.text = ""
        self.passwordText.text = ""
    }
    
    
    
    func setUpButtons(){
        Utilities.styleFilledButton(loginButton)
    }

    func validateFields() -> String?{
        if emailIDText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        return nil
    }
    
    @IBAction func LoginNormal(_ sender: Any) {
        let error = validateFields()
        if error != nil{
            NotificationBanner.show(error!)
        }else{
            let email = emailIDText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            userEmail = email
            userPassword = password
            Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
                if let err = err as? NSError {
                    //NotificationBanner.show(err!.localizedDescription)
                    switch AuthErrorCode(rawValue: err.code) {
                    case .operationNotAllowed:
                        NotificationBanner.show("This operation is not allowed")
                    case .userDisabled:
                        NotificationBanner.show("This user has been disabled")
                    case .invalidEmail:
                        NotificationBanner.show("The email-ID entered is ill-formed")
                    case .wrongPassword:
                        NotificationBanner.show("Wrong password has been entered")
                    default:
                        NotificationBanner.show("There is no registered user with given credentials")
                        print(err.localizedDescription)
                    }
                }else{
                    if self.changePassFlag == 1{
                        self.changePassFlag = 0
                        self.navigationController?.popViewController(animated: true)
                    }
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
        
    }
    
    
    @IBAction func ForgotPassword(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetPassVC") as? ResetPasswordViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func RegisterNewUser(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}


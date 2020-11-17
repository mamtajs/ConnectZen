//
//  ViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/9/20.
//

import UIKit
import Firebase
import FirebaseUI

/*extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = "Login"
    }
}*/

class LoginViewController: UIViewController, FUIAuthDelegate, UIApplicationDelegate{

    var authUI: FUIAuth?
    
    @IBOutlet weak var emailIDText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginGFButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
    }
    
    
    
    func setUpButtons(){
        Utilities.styleFilledButton(loginButton)
        Utilities.styleFilledButton(loginGFButton)
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
            Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    NotificationBanner.show(err!.localizedDescription)
                }else{
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
        
    }
    
    
    @IBAction func LoginGoogleFacebook(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth()
        ]
        authUI!.providers = providers
        let authViewController = authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func RegisterNewUser(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //Sign in successful, move to home screen
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("user signed in")
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        //authDataResult?.user.displayName
    }
    
    // Google and Facebook authentication handler
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let abc = FUIAuthPickerViewController(authUI: authUI)
        abc.view.backgroundColor = UIColor.white
        return abc
    }
}


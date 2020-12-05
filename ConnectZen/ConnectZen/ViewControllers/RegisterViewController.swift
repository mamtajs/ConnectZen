//
//  RegisterViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/22/20.
//

import UIKit
import Firebase
import FirebaseUI

class RegisterViewController: UIViewController, FUIAuthDelegate, UIApplicationDelegate {
    

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailIDText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var registerGFButton: UIButton!
    
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        // Do any additional setup after loading the view.
    }
    
    func setUpButtons(){
        Utilities.styleFilledButton(nextButton)
        Utilities.styleFilledButton(registerGFButton)
    }

    func validateFields() -> String?{
        if emailIDText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        //let cleanedEmail = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        /*if Utilities.isEmailValid(cleanedEmail) == false{
            return "The email-ID is not in the correct format."
        }*/
        
        let cleanedPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Your password should be atleast 8 characters long, with atleast one number and one special character."
        }
        
        let cleanedConfPassword = confirmPasswordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedPassword != cleanedConfPassword{
            return "Passwords do not match."
        }
        return nil
    }
    
    @IBAction func NextTapped(_ sender: Any) {
        let error = validateFields()
        if error != nil{
            NotificationBanner.show(error!)
        }else{
            //create the user
            let name = nameText.text!
            let email = emailIDText.text!
            let password = passwordText.text!
    
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if(err != nil){
                    NotificationBanner.show(err!.localizedDescription)
                }
                else{
                    self.db.collection("Users").document(result!.user.uid).setData([
                        "Name": name,
                        "EmailID": email,
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                    // Going to calendar (for now) screen (ANOTHER WAY IN VIDEO)
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PopUpVC") as? PopUpViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
    }
    
    
    @IBAction func SignUpGoogleFacebook(_ sender: Any) {
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
    
    //Sign in successful
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("New user registered")
        let uid = authDataResult?.user.uid
        let uname = authDataResult?.user.displayName
        let uemailID = authDataResult?.user.email
        
        // TO DO- Change
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        //authDataResult?.user.displayName
        
        //Entering data to firestore
        db.collection("Users").document(uid!).setData([
            "Name": uname!,
            "EmailID": uemailID!,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

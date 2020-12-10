//
//  RegisterViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/22/20.
//

import UIKit
import Firebase
import FirebaseUI
import PhoneNumberKit

class RegisterViewController: UIViewController, FUIAuthDelegate, UIApplicationDelegate {
    

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailIDText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    let phoneNumberKit = PhoneNumberKit()
    
    
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordText.adjustsFontSizeToFitWidth = false
        self.confirmPasswordText.adjustsFontSizeToFitWidth = false
        //self.passwordText.autocorrectionType = .no
        self.passwordText.isSecureTextEntry = true
        //self.confirmPasswordText.autocorrectionType = .no
        self.confirmPasswordText.isSecureTextEntry = true
        setUpButtons()
        // Do any additional setup after loading the view.
    }
    
    func setUpButtons(){
        Utilities.styleFilledButton(nextButton)
    }

    func validateFields() -> String?{
        // TO DO: Uncomment
        if emailIDText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            phoneNumberText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        //let cleanedEmail = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        /*if Utilities.isEmailValid(cleanedEmail) == false{
            return "The email-ID is not in the correct format."
        }*/
        do {
            try phoneNumberKit.parse(phoneNumberText!.text!, withRegion: "US")
        }
        catch {
            return "Phone Number is not in the correct format"
        }
        
        let cleanedPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Password should be atleast 8 characters long, with atleast one number and one special character."
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
            let phoneNumber = phoneNumberText.text!
            let password = passwordText.text!
            let calUpdationAccess: Bool = false
    
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if(err != nil){
                    NotificationBanner.show(err!.localizedDescription)
                }
                else{
                    self.db.collection("Users").document(result!.user.uid).setData([
                        "Name": name,
                        "EmailID": email,
                        "Phone Number": phoneNumber,
                        "Calendar Updation Access": calUpdationAccess
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
}

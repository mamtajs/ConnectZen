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
    //var errorStatus = 0
    
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        
        self.passwordText.adjustsFontSizeToFitWidth = false
        self.confirmPasswordText.adjustsFontSizeToFitWidth = false
        //self.passwordText.autocorrectionType = .no
        //self.passwordText.isSecureTextEntry = true
        //self.confirmPasswordText.autocorrectionType = .no
        //self.confirmPasswordText.isSecureTextEntry = true
        setUpButtons()
        // Do any additional setup after loading the view.
        
        emailIDText.keyboardType = UIKeyboardType.emailAddress
        phoneNumberText.keyboardType = UIKeyboardType.phonePad
    }
    
    func setUpButtons(){
        Utilities.styleFilledButton(nextButton, cornerRadius: xLargeCornerRadius)
    }
    
    
    func checkPhoneNumber(){
        
    }
    func validateFields(){
        // TO DO: Uncomment
        if emailIDText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            phoneNumberText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            NotificationBanner.showFailure("Please fill in all fields.")
            //self.errorStatus = 1
        }
        let cleanedPassword = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            NotificationBanner.showFailure("Password should be atleast 8 characters long, with atleast one number and one special character.")
            //self.errorStatus = 1
        }
        
        let cleanedConfPassword = confirmPasswordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedPassword != cleanedConfPassword{
            NotificationBanner.showFailure("Passwords do not match.")
            //self.errorStatus = 1
        }
    }
    
    
    @IBAction func NextTapped(_ sender: Any) {
        validateFields()
        do {
            try phoneNumberKit.parse(phoneNumberText!.text!, withRegion: "US")
        }
        catch {
            NotificationBanner.showFailure("Phone Number is not in the correct format.")
        }
        var phoneNumbers = Set<String>()
        self.db.collection("Users").getDocuments() {(querySnapShot, error) in
            if let error = error{
                print("Error getting documents: \(error)")
            }
            else{
                for doc in querySnapShot!.documents{
                    if doc.get("Phone Number") != nil{
                        phoneNumbers.insert(doc["Phone Number"] as! String)
                    }
                    else{
                        print("Error reading the user document")
                        
                    }
                }
                if phoneNumbers.contains(self.phoneNumberText!.text!){
                    NotificationBanner.showFailure("The phone number is already in use by another account.")
                }else{
                    //create the user
                    let name = self.nameText.text!
                    let email = self.emailIDText.text!
                    let phoneNumber = self.phoneNumberText.text!
                    let password = self.passwordText.text!
                    let calUpdationAccess: Bool = false
                    let quotesEnabled: Bool = false
                    
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                        if(err != nil){
                            NotificationBanner.showFailure(err!.localizedDescription)
                        }
                        else{
                            self.db.collection("Users").document(result!.user.uid).setData([
                                "Name": name,
                                "EmailID": email,
                                "Phone Number": phoneNumber,
                                "Calendar Updation Access": calUpdationAccess,
                                "Quotes Enabled": quotesEnabled
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
        
    }
    
}

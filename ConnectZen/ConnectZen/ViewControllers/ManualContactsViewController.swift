//
//  ManualContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/2/20.
//

import UIKit
import PhoneNumberKit
import Firebase
import FirebaseUI

class ManualContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var NewContactsTableView: UITableView!
    
    @IBOutlet weak var contactsAddedButton: UIButton!
    var connectWith = Array<Person>()
    var connectedWith = Array<Person>()
    let phoneNumberKit = PhoneNumberKit()
  
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    var registeredPeople = Dictionary<String, [String]>()
    var unRegisteredPeople = Dictionary<String, [String]>()
    var allFriends = Dictionary<String, [String]>()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(connectWith.count)")
        if(connectWith.count > 0){
            print("Enabling add contact button")
            contactsAddedButton.isEnabled = true
            Utilities.styleFilledButton(contactsAddedButton, cornerRadius: xLargeCornerRadius)
        }
        else{
            contactsAddedButton.isEnabled = false
            Utilities.disabledFilledButton(contactsAddedButton, cornerRadius: xLargeCornerRadius)
        }
        return connectWith.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Adding new cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.ActionButton.tintColor =  UIColor(red: 0.836095, green: 0.268795, blue: 0.178868, alpha: 1)
        cell.cellDelegate = self
       
        //let cell = UITableViewCell()
        print(indexPath)
        //cell.textLabel?.text = "\(connectWith[indexPath.row].contactName) \t \(connectWith[indexPath.row].PhoneNumber)"
        cell.ContactName.text = "\(connectWith[indexPath.row].contactName)"
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NewContactsTableView.delegate = self
        self.NewContactsTableView.dataSource = self
        self.contactsAddedButton.isEnabled = false

        
        Utilities.disabledFilledButton(contactsAddedButton, cornerRadius: xLargeCornerRadius)

        /*self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc{
                let userExistingFriends:[String:[String]] = doc["Friends"] as! [String : [String]]
                if userExistingFriends.isEmpty{
                    self.NewContactsTableView.delegate = self
                    self.NewContactsTableView.dataSource = self
                    self.contactsAddedButton.isEnabled = false
                }else{
                    
                }
            }
            else{
                print("Error reading the user document")
            }
            
        }*/
    }
    

    @IBAction func AddNewContact(_ sender: Any) {
        showAlertWithTextField()
        print("Printing count ", connectWith.count)
        
    }
    
    // Return true if phone number is valid and false otherwise
    func PhoneNumberIsValid(phone: String, region: String) -> Bool{
        do {
            let phoneNumber = try phoneNumberKit.parse(phone)
            //let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(phone, withRegion: region, ignoreType: true)
            //print("phoneNumberCustomDefaultRegion: \(phoneNumberCustomDefaultRegion)")
            return true
        }
        catch {
            print("Generic parser error")
            return false
        }
    }
    
    //  Simple Alert with Text input
    func showAlertWithTextField() {
        let alertController = UIAlertController(title: "Add New Contact", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { [self] (_) in
            let txtField = alertController.textFields?.first
            let text = txtField!.text
            let phoneField = alertController.textFields?.last
            let phone = phoneField!.text
            if( (text != "") && (phone != "")) {
                // operations
                print("Name==>" + text!)
                print("Phone==>" + phone!)
                
                // Check if phoneNumber is valid, if not show error
                if(PhoneNumberIsValid(phone: phone!, region: "US")){
                    self.connectWith.append(Person(contactName: text!, PhoneNumber: phone!))
                    
                    NewContactsTableView.reloadData()
                    
                    // show message of added
                    //showToast(controller: self, message: "Contact \(text!) added", seconds: 2, colorBackground: .systemGreen, title: "Success")
                }
                else{
                    NotificationBanner.showFailure("Contact Number is Invalid! ")
                    //showToast(controller: self, message: "Contact Number is Invalid! ", seconds: 3, colorBackground: .systemRed, title: "Error")
                }
            }
            else{
                // Show error
                NotificationBanner.showFailure("Please enter both contact name and phone number to connect.")
                //showToast(controller: self, message: "Error: Please enter both contact name and phone number to connect.", seconds: 2, colorBackground: .systemRed, title: "Error")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "Contact name"
            textField.keyboardType = UIKeyboardType.namePhonePad
        }
        alertController.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "Phone number"
            textField.keyboardType = UIKeyboardType.phonePad
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func showInviteAlert(){
        let alertController = UIAlertController(title: "Add Friends", message: "All of the \(connectWith.count) people have been added as your friends. However \(unRegisteredPeople.count) of these people are not currently registered on ConnectZen. You can go ahead and invite them. Do you want to invite them?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Invite", style: .default) { [self] (_) in
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "InviteVC") as? InviteViewController
            var names:[String] = []
            for val in unRegisteredPeople.values{
                names.append(val[0])
            }
            vc?.unRegisteredPeople = names
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Don't Invite", style: .default) { (_) in
            if friendsPageFlag == 1 {
                friendsPageFlag = 0
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    func loadFromFirebase() {
      let query = db.collection("Users")
      query.getDocuments { snapshot, error in
        print(error ?? "No error.")
        var IDSet = Dictionary<String, registeredPerson>()
        for doc in snapshot!.documents {
            IDSet[doc.get("Phone Number") as! String] = registeredPerson(emailID: doc.get("EmailID") as! String, ID: doc.documentID)
        }
        for eachPerson in self.connectWith {

            
            if IDSet.keys.contains((eachPerson.PhoneNumber)){
                var tempArray:[String] = []
                tempArray.append(eachPerson.contactName)
                tempArray.append(IDSet[eachPerson.PhoneNumber]?.emailID ?? "")
                tempArray.append(IDSet[eachPerson.PhoneNumber]?.ID ?? "")
                self.registeredPeople[eachPerson.PhoneNumber] = tempArray
            }else{
                var tempArray:[String] = []
                tempArray.append(eachPerson.contactName)
                tempArray.append("")
                tempArray.append("")
                self.unRegisteredPeople[eachPerson.PhoneNumber] = tempArray
            }
        }
        print("REG: \(self.registeredPeople)") // 1 what will this print now?
        print(self.unRegisteredPeople)
        self.completion()
        
        
        // TODO: Check registerd and pause app. How????
      }
    }
    
    
    func completion(){
        print("Registered friends")
        for friend in self.registeredPeople{
            print(friend.key, friend.value)
        }
        self.allFriends += self.registeredPeople
        self.allFriends += self.unRegisteredPeople
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Friends": self.allFriends], merge: true)
        //self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Friends": self.unRegisteredPeople], merge: true)
        if self.connectWith.count != self.registeredPeople.count{
            self.showInviteAlert()
        }else{
            showToast(controller: self, message: "\(self.registeredPeople.count) people have been added as your friends on ConnectZen", seconds: 4, colorBackground: .systemGreen, title: "Success")
            if friendsPageFlag == 1 {
                friendsPageFlag = 0
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: { [self] in
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                })
            }
        }
    }

    
    @IBAction func ContactsAdded(_ sender: Any) {
        loadFromFirebase()
    }
}

extension ManualContactsViewController: ContactTableViewCellDelegate {
    func ContactTableViewCell(cell: ContactTableViewCell, didTappedThe button: UIButton?) {
        guard let indexPath = NewContactsTableView.indexPath(for: cell) else  { return }
        print("Cell action in row: \(indexPath.row) \(String(describing: cell.ActionButton.tintColor))")
        
        // Button color is green
        if(cell.ActionButton.tintColor == UIColor(red: 0, green: 0.405262, blue: 0.277711, alpha: 1)){
            // Can not happen so error
            print("Error: Color can not be found")
        }
        else{ // Button color is red
            
            // Show tool tip of removed from connection
            //showToast(controller: self, message: "\(String(cell.ContactName.text!)) removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            //Remove person from list of contacts
            connectWith.remove(at: indexPath.row)
            
            print(connectWith)
            NewContactsTableView.reloadData()
        }
        
    }
}

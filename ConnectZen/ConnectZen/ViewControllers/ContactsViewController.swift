//
//  ContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit
import Contacts
import Firebase
import FirebaseUI

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var contacts = [CNContact]()
    var contactNames = [String]()
    var connectWith = Dictionary<Int, Person>() // Saved selected contacts
    var registeredPeople = Dictionary<String, [String]>()
    var unRegisteredPeople = Dictionary<String, [String]>()
    var allFriends = Dictionary<String, [String]>()
    var addedFriends = Set<String>()
    
   
    @IBOutlet weak var ContactsTableView: UITableView!
    @IBOutlet weak var contactsSelectedButton: UIButton!
    
    var authUI: FUIAuth?
    let db = Firestore.firestore()

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of rows
        print("Number of Contacts: ", contactNames.count)
        
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
       
        cell.cellDelegate = self
        print(indexPath)
        cell.ContactName.text = "\(String(contacts[indexPath.row].givenName) + " " + String(contacts[indexPath.row].familyName))"
        if(addedFriends.firstIndex(of: cell.ContactName.text!) == nil){
            let image = UIImage(systemName: "plus.circle")
            cell.ActionButton.setBackgroundImage(image, for: .normal)
            cell.ActionButton.tintColor = brightColor
        }
        else{
            let image = UIImage(systemName: "minus.circle")
            cell.ActionButton.setBackgroundImage(image, for: .normal)
            cell.ActionButton.tintColor = UIColor.red
        }
        
        return cell
    }
    
    
    
    func fetchContacts(){
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                if(contact.givenName != ""){
                    self.contacts.append(contact)
                }
                   
            }
        }
        catch {
            print("Error: unable to fetch contacts")
        }
        print(self.contacts)
        for index in 0...self.contacts.count-1{
            print(self.contacts[index].phoneNumbers[0].value.stringValue, index)
        }
        //exit(20)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc, doc.exists {
                if doc.get("Friends") != nil{
                    let userExistingFriends:[String:[String]] = doc["Friends"] as! [String : [String]]
                    self.allFriends += userExistingFriends
                    if userExistingFriends.isEmpty == false {
                        let contactsTemp = self.contacts
                        self.contacts.removeAll()
                        for idx in 0...contactsTemp.count-1{
                            if (userExistingFriends.index(forKey: contactsTemp[idx].phoneNumbers[0].value.stringValue) == nil){
                                self.contacts.append(contactsTemp[idx])
                            }
                        }
                        
                    }
                    
                    print(self.contacts)
                    self.ContactsTableView.reloadData()
                }else{
                    print("Document does not exist")
                }
            }
            else{
                print("Error getting the document")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContactsTableView.delegate = self
        ContactsTableView.dataSource = self
        
        fetchContacts()
        contactsSelectedButton.isEnabled = false
        Utilities.disabledFilledButton(contactsSelectedButton, cornerRadius: xLargeCornerRadius)
        print("Button disabled")
        self.addedFriends.removeAll()
        //navigationController?.navigationItem.hidesBackButton = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        if friendsPageFlag == 1{
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
            self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "Select Contacts"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //friendsPageFlag = 0
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
                /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                self.navigationController?.pushViewController(vc!, animated: true)*/
                navigateToTabBar()
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

            
            if IDSet.keys.contains((eachPerson.value.PhoneNumber)){
                var tempArray:[String] = []
                tempArray.append(eachPerson.value.contactName)
                tempArray.append(IDSet[eachPerson.value.PhoneNumber]?.emailID ?? "")
                tempArray.append(IDSet[eachPerson.value.PhoneNumber]?.ID ?? "")
                self.registeredPeople[eachPerson.value.PhoneNumber] = tempArray
            }else{
                var tempArray:[String] = []
                tempArray.append(eachPerson.value.contactName)
                tempArray.append("")
                tempArray.append("")
                self.unRegisteredPeople[eachPerson.value.PhoneNumber] = tempArray
            }
        }
        print("REG: \(self.registeredPeople)") // 1 what will this print now?
        print(self.unRegisteredPeople)
        self.completion()
      }
    }
    
    
    func completion(){
        self.allFriends += self.registeredPeople
        self.allFriends += self.unRegisteredPeople
        //self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Friends": self.registeredPeople], merge: true)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Friends": self.allFriends], merge: true)
        if self.connectWith.count != self.registeredPeople.count{
            self.showInviteAlert()
        }else{
            showToast(controller: self, message: "\(self.registeredPeople.count) people have been added as your friends on ConnectZen", seconds: 1, colorBackground: .systemGreen, title: "Success")
            if friendsPageFlag == 1 {
                friendsPageFlag = 0
                navigateToTabBar()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: { [self] in
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                })
            }
            
        }
    }

    
 
    @IBAction func contactsSelected(_ sender: Any) {
        self.loadFromFirebase()
    }
    
}

extension ContactsViewController: ContactTableViewCellDelegate {
    
    func ContactTableViewCell(cell: ContactTableViewCell, didTappedThe button: UIButton?) {
        guard let indexPath = ContactsTableView.indexPath(for: cell) else  { return }
        print("Cell action in row: \(indexPath.row) \(String(describing: cell.ActionButton.tintColor))")
        
        // Button color is green
        if(cell.ActionButton.tintColor == brightColor){
            // Change image to minus
            let image = UIImage(systemName: "minus.circle")
            cell.ActionButton.setBackgroundImage(image, for: .normal)
            // Change color to red
            cell.ActionButton.tintColor = UIColor.red
            cell.type = true
            // Add person to dictonary of contacts
            let p = Person(contactName: String(cell.ContactName.text!), PhoneNumber: contacts[indexPath.row].phoneNumbers[0].value.stringValue);
            connectWith[indexPath.row] = p
            addedFriends.insert(cell.ContactName.text!)
            if(self.connectWith.count > 0){
                contactsSelectedButton.isEnabled = true
                Utilities.styleFilledButton(contactsSelectedButton, cornerRadius: xLargeCornerRadius)
                print("Button enabled")
            }
            else{
                contactsSelectedButton.isEnabled = false
                Utilities.disabledFilledButton(contactsSelectedButton, cornerRadius: xLargeCornerRadius)
                print("Button disabled")
            }
            // Show tool tip of added to contacts
            //showToast(controller: self, message: "\(String(cell.ContactName.text!)) added", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            print(connectWith)
        }
        else{ // Button color is red
            // Change image to plus
            
            let image = UIImage(systemName: "plus.circle")
            cell.ActionButton.setBackgroundImage(image, for: .normal)
            // Change color to green
            cell.ActionButton.tintColor = brightColor
            cell.type = false
            //Remove person from dictonary of contacts
            addedFriends.remove(at: addedFriends.firstIndex(of: cell.ContactName.text!)!)
            connectWith[indexPath.row] = nil
            if(self.connectWith.count > 0){
                contactsSelectedButton.isEnabled = true
                Utilities.styleFilledButton(contactsSelectedButton, cornerRadius: xLargeCornerRadius)
                print("Button enabled")
            }
            else{
                contactsSelectedButton.isEnabled = false
                Utilities.disabledFilledButton(contactsSelectedButton, cornerRadius: xLargeCornerRadius)
                print("Button disabled")
            }
            // Show tool tip of removed from connection
            //showToast(controller: self, message: "\(String(cell.ContactName.text!)) removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            print(connectWith)
        }
        
    }
}

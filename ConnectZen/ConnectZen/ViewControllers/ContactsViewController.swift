//
//  ContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var contacts = [CNContact]()
    var contactNames = [String]()
    var connectWith = Dictionary<Int, Person>() // Saved selected contacts
    
   
    @IBOutlet weak var ContactsTableView: UITableView!
    @IBOutlet weak var ContactsSelectedButton: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of rows
        print("Number of Contacts: ", contactNames.count)
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.ActionButton.tintColor = brightColor
        cell.cellDelegate = self
        print(indexPath)
        cell.ContactName.text = "\(String(contacts[indexPath.row].givenName) + " " + String(contacts[indexPath.row].familyName))"
        
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
            print(self.contacts)
            ContactsTableView.reloadData()
        }
        catch {
            print("Error: unable to fetch contacts")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContactsTableView.delegate = self
        ContactsTableView.dataSource = self
        
        fetchContacts()
        Utilities.styleFilledButton(ContactsSelectedButton)
    }
    
    @IBAction func ContactsSelectedTapped(_ sender: Any) {
        // TODO: Find people already registered with app
        
        // TODO: For people not registered show popUp Message/Invitation screen
        
        // TODO: Add the people already registered on the app as friends
        
        // Direct to time and day preferences scene
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
        self.navigationController?.pushViewController(vc!, animated: true)
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
            cell.ActionButton.tintColor = UIColor(red: 0.836095, green: 0.268795, blue: 0.178868, alpha: 1)
            
            // Add person to dictonary of contacts
            let p = Person(contactName: String(cell.ContactName.text!), PhoneNumber: contacts[indexPath.row].phoneNumbers[0].value.stringValue);
            connectWith[indexPath.row] = p
            
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
            
            //Remove person from dictonary of contacts
            connectWith[indexPath.row] = nil
            
            // Show tool tip of removed from connection
            //showToast(controller: self, message: "\(String(cell.ContactName.text!)) removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            print(connectWith)
        }
        
    }
}

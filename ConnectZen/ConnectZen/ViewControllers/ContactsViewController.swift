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
    
    @IBOutlet weak var ContactsTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of rows
        print("Number of Contacts: ", contactNames.count)
        return self.contactNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        
        print(indexPath)
        cell.ContactName.text = "\(contactNames[indexPath.row])"
        
        return cell
    }
    
    func fetchContacts(){
        let contactStore = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
                self.contactNames.append(String(contact.givenName) + " " + String(contact.familyName))
            }
            print(self.contactNames)
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
    }
    

}

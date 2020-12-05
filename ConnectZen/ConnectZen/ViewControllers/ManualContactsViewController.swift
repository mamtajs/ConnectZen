//
//  ManualContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/2/20.
//

import UIKit
import PhoneNumberKit

class ManualContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var NewContactsTableView: UITableView!
    var connectWith = Array<Person>()
    let phoneNumberKit = PhoneNumberKit()
    @IBOutlet weak var ContactsAddedButton: UIButton!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(connectWith.count)")
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
        
        NewContactsTableView.delegate = self
        NewContactsTableView.dataSource = self
        
        Utilities.styleFilledButton(ContactsAddedButton)
    }

    @IBAction func AddNewContact(_ sender: Any) {
        showAlertWithTextField()
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
                    showToast(controller: self, message: "Contact \(text!) added", seconds: 2, colorBackground: .systemGreen, title: "Success")
                }
                else{
                    showToast(controller: self, message: "Contact Number is Invalid! ", seconds: 3, colorBackground: .systemRed, title: "Error")
                }
                
            }
            else{
                // Show error
                showToast(controller: self, message: "Error: Please enter both contact name and phone number to connect.", seconds: 2, colorBackground: .systemRed, title: "Error")
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
    
    @IBAction func ContactsAdded(_ sender: Any) {
        // TODO: Find people already registered with app
        
        // TODO: For people not registered show popUp Message/Invitation screen
        
        // TODO: Add the people already registered on the app as friends
        
        // Direct to time and day preferences scene
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
        self.navigationController?.pushViewController(vc!, animated: true)
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
            showToast(controller: self, message: "\(String(cell.ContactName.text!)) removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            //Remove person from list of contacts
            connectWith.remove(at: indexPath.row)
            
            print(connectWith)
            NewContactsTableView.reloadData()
        }
        
    }
}

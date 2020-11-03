//
//  ManualContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/2/20.
//

import UIKit

class ManualContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var NewContactsTableView: UITableView!
    var connectWith = Array<Person>()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(connectWith.count)")
        return connectWith.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        //cell.ActionButton.tintColor = UIColor(red: 0, green: 0.405262, blue: 0.277711, alpha: 1)
        //cell.cellDelegate = self
        print("Adding new cell")
        let cell = UITableViewCell()
        print(indexPath)
        cell.textLabel?.text = "\(connectWith[indexPath.row].contactName) \t \(connectWith[indexPath.row].PhoneNumber)"
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NewContactsTableView.delegate = self
        NewContactsTableView.dataSource = self
        
    }

    @IBAction func AddNewContact(_ sender: Any) {
        showAlertWithTextField()
        
       // NewContactsTableView.reloadData()
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
                self.connectWith.append(Person(contactName: text!, PhoneNumber: phone!))
                
                NewContactsTableView.reloadData()
                
                // show message of added
                showToast(controller: self, message: "Contact \(text!) added", seconds: 2, colorBackground: .systemGreen)
                
            }
            else{
                // Show error
                showToast(controller: self, message: "Error: Please enter both contact name and phone number to connect.", seconds: 2, colorBackground: .systemRed)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Contact name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Phone number"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//
//  ManualContactsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/2/20.
//

import UIKit

class ManualContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var connectWith = Dictionary<Int, Person>()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectWith.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        //cell.ActionButton.tintColor = UIColor(red: 0, green: 0.405262, blue: 0.277711, alpha: 1)
        //cell.cellDelegate = self
        let cell = UITableViewCell()
        print(indexPath)
        cell.textLabel?.text = "\(connectWith[indexPath.row]?.contactName) \(connectWith[indexPath.row]?.PhoneNumber)"
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func AddNewContact(_ sender: Any) {
        showAlertWithTextField()
    }
    
    //  Simple Alert with Text input
    func showAlertWithTextField() {
        let alertController = UIAlertController(title: "Add new Contact", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                // operations
                print("Text==>" + text)
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

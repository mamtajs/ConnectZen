//
//  ViewAndEditFriendsViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/8/20.
//

import UIKit
import Firebase


class ViewAndEditFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var contactsTableView: UITableView!
    let db = Firestore.firestore()
    var userExistingFriends = Dictionary<String, [String]>()
    var keysArraySorted:[String] = []
    var valuesArraySorted = [[String]]()

    @IBOutlet weak var doneButton: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.valuesArraySorted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableCell") as! ContactsTableCell
        cell.cellDelegate = self
        print("IndexPath- ", indexPath)
        cell.contactName.text = self.valuesArraySorted[indexPath.row][0]
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        Utilities.styleFilledButton(doneButton, cornerRadius: xLargeCornerRadius)
        
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc{
                if doc.get("Friends") != nil{
                    self.userExistingFriends = doc["Friends"] as! [String : [String]]
                    let sorted = self.userExistingFriends.sorted { $0.key < $1.key }
                    print(sorted)
                    self.keysArraySorted = Array(sorted.map({ $0.key }))
                    print(self.keysArraySorted)
                    self.valuesArraySorted = Array(sorted.map({ $0.value }))
                    print(self.valuesArraySorted)
                    self.contactsTableView.reloadData()
                }
            }
            else{
                print("Error reading the user document")
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*let navigationController2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "settingNavigationControllerVC") as? UINavigationController
        navigationController2?.setNavigationBarHidden(true, animated: animated)*/
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "View/Edit friends"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //print("View controllers", self.navigationController?.viewControllers)
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addContactTapped(_ sender: Any) {
        friendsPageFlag = 1
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PopUpVC") as? PopUpViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func updateContactsTapped(_ sender: Any) {
        /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
        self.navigationController?.pushViewController(vc!, animated: true)*/
        navigateToTabBar()
    }
    
    
    func showDeleteConfirmAlert(index: Int){
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure that you want to remove \(self.valuesArraySorted[index][0]) from your friends list?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [self] (_) in
            let fieldToBeDeleted = "Friends." + self.keysArraySorted[index]
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).updateData([fieldToBeDeleted : FieldValue.delete()]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Friend document successfully updated")
                }
            }
            self.keysArraySorted.remove(at: index)
            self.valuesArraySorted.remove(at: index)
            contactsTableView.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
  

}

extension ViewAndEditFriendsViewController: ContactsTableCellDelegate{
    
    func ContactsTableCell(cell: ContactsTableCell, didTappedThe button: UIButton?) {
        
        guard let indexPath = contactsTableView.indexPath(for: cell) else  { return }
        print("button tapped at- ", indexPath)
        self.showDeleteConfirmAlert(index: indexPath.row)
    }
}

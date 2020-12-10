//
//  InviteViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/18/20.
//

import UIKit

class InviteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var UnregisteredTableView: UITableView!
    var unRegisteredPeople: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UnregisteredTableView.dataSource = self
        UnregisteredTableView.delegate = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.unRegisteredPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let personName = self.unRegisteredPeople[indexPath.row]
        cell.textLabel!.text = personName
        return cell
    }
    
    @IBAction func ShareTapped(_ sender: Any) {
        let message = "Hi, I would like to invite you to start using ConnectZen application. <INSERT LINK>"
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                            UIActivity.ActivityType.addToReadingList,
                                            UIActivity.ActivityType.saveToCameraRoll]
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func DoneTapped(_ sender: Any) {
        self.unRegisteredPeople.removeAll()
        if friendsPageFlag == 1 {
            friendsPageFlag = 0
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

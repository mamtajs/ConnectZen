//
//  HomeViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/8/20.
//

import UIKit
import Firebase
import FirebaseUI
import SideMenu


class HomeViewController: UIViewController, MenuControllerDelegate {
    
    let db = Firestore.firestore()
    
    private var sideMenu: SideMenuNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //To hide navigation bar in a particular view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func SettingsButtonTapped(_ sender: Any) {
        print("Settings button tapped")
        let menu = MenuController(with: ["View/Edit Friends", "View/Edit Day-Time Preferences", "Notifications Settings", "Provide Feedback", "Change Password", "Delete Account", "Sign Out"])
        menu.delegate = self
        
        
        let navigationView = UIView()
        let label = UILabel()
        label.text = "ConnectZen"
        label.sizeToFit()
        label.center = navigationView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "Logo.png")
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        navigationView.addSubview(label)
        navigationView.addSubview(image)
        menu.navigationItem.titleView = navigationView
        navigationView.sizeToFit()

        
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        sideMenu?.menuWidth = min(view.frame.width, view.frame.height) * 0.80
        sideMenu?.title = "ConnectZen"
       
        
        //sideMenu?.setNavigationBarHidden(true, animated: false)
        
        SideMenuSettings().presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        present(sideMenu!, animated: true)
    }
    
    
    func fetchingjsonData(){
        guard let path = Bundle.main.path(forResource: "Quotes", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        do{
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            guard let array = json as? [Any] else {return}
            var counter = 21
            for user in array{
                guard let userDic = user as? [String:Any] else {return}
                guard let title = userDic["title"] as? String else {return}
                guard let author = userDic["author"] as? String else {return}
                print(title, author)
                self.db.collection("Quotes").document().setData([
                    "Title": title,
                    "QuotesID": counter,
                    "Author": author,
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                counter += 1
            }
        }catch{
            print(error)
        }
        
    }
    
    
    
    @IBAction func AnalyticsButtonDashboard(_ sender: Any) {
        /*if let localData = self.readLocalFile(forName: "Quotes"){
            self.parse(jsonData: localData)
        }*/
        //self.fetchingjsonData()
        
        
        /*var count = 1
        self.db.collection("Quotes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in querySnapshot!.documents {
                    print(doc.documentID, count)
                    self.db.collection("Quotes").document(doc.documentID as String).setData(["QuotesID":count], merge: true)
                    count = count + 1;
                }
                //exit(20)
            }
        }*/
        print("Analytics button tapped")
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalyticsVC") as? AnalyticsDashboardViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func CalendarButtonTapped(_ sender: Any) {
    }
    @IBAction func RewardsButtonTapped(_ sender: Any) {
    }
    func showDeleteAccountConfirmAlert(){
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure that you want to delete your account? Once deleted you will not be able to recover your account again.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [self] (_) in
            let user = Auth.auth().currentUser
            user?.delete { error in
              if let error = error {
                // An error happened.
              } else {
                self.db.collection("Users").document(Auth.auth().currentUser!.uid).delete()
                self.navigationController?.popToRootViewController(animated: true)
              }
            }
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {
            if named == "Notifications Settings"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationSettingsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if named == "Change Password"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePassVC") as? ChangePasswordViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if named == "Provide Feedback"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FeedbackVC") as? FeedbackViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if named == "View/Edit Friends"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewEditVC") as? ViewAndEditFriendsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if named == "View/Edit Day-Time Preferences"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if named == "Delete Account"{
                self.showDeleteAccountConfirmAlert()
            }
            else if named == "Sign Out"{
                let firebaseAuth = Auth.auth()
                do{
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error Signing out- %@", signOutError)
                }
                self.navigationController?.popToRootViewController(animated: true)
               
            }
        })
    }

}


protocol MenuControllerDelegate{
    func didSelectMenuItem(named: String)
}

class MenuController: UITableViewController{
    
    public var delegate: MenuControllerDelegate?
    private let menuItems: [String]
    let menuSymbols = ["person.2", "square.and.pencil", "bell.badge", "ellipsis.bubble", "lock.rotation", "trash", "lock"]
    
    init(with menuItems: [String]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        let image:UIImage = UIImage(systemName: self.menuSymbols[indexPath.row])!
        print("The loaded image: \(image)")
        cell.imageView!.image = image
        cell.imageView?.tintColor = .black
        cell.backgroundColor = .white
        cell.selectionStyle = .gray
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = menuItems[indexPath.row]
        delegate?.didSelectMenuItem(named: selectedItem)
    }
}

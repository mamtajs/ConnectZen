//
//  SettingsMenuViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 12/10/20.
//

import UIKit
import Firebase
import FirebaseUI
import SideMenu

class SettingsMenuViewController: UIViewController, MenuControllerDelegate, SideMenuNavigationControllerDelegate {
    
    var sideMenu: SideMenuNavigationController?
    let db = Firestore.firestore()
    let menu = MenuController(with: ["View/Edit Friends", "View/Edit Day-Time Preferences", "Notifications Settings", "Provide Feedback", "Change Password", "Delete Account", "Sign Out", "Close Settings"])
    var panGesture = UIPanGestureRecognizer()
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View appeared")
        blurView.bounds = self.view.bounds
        //self.animateIn(desiredView: self.blurView)
        //self.presetingSideMenu()
    }
    
    func presetingSideMenu(){
        self.animateIn(desiredView: self.blurView)
        menu.delegate = self
        let navigationView = UIView()
        let label = UILabel()
        label.text = " ConnectZen"
        label.sizeToFit()
        label.center = navigationView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "LOGOTrans.png")
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
        sideMenu?.menuWidth = min(view.frame.width, view.frame.height) * 1
        //sideMenu?.title = "ConnectZen"
        sideMenu?.dismissOnPush = true
        sideMenu?.dismissOnPresent = true
        
        //sideMenu?.setNavigationBarHidden(true, animated: false)
        
        SideMenuSettings().presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        //SideMenuManager.default.addPanGestureToPresent(toView: view)
        present(sideMenu!, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.popToRootViewController(animated: true)
        self.presetingSideMenu()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "Settings"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
   
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("side meny disappearing")
        //self.tabBarController?.selectedIndex = 2
        animateOut(desiredView: blurView)
    }
    
    func didSelectMenuItem(named: String) {
        //sideMenu?.dismiss(animated: true, completion: {
            if named == "Notifications Settings"{
                
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationSettingsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                sideMenu?.dismiss(animated: true, completion: nil)
            }
            else if named == "Change Password"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePassVC") as? ChangePasswordViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                sideMenu?.dismiss(animated: true, completion: nil)
            }
            else if named == "Provide Feedback"{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FeedbackVC") as? FeedbackViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                sideMenu?.dismiss(animated: true, completion: nil)
            }
            else if named == "View/Edit Friends"{

                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewEditVC") as? ViewAndEditFriendsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                sideMenu?.dismiss(animated: true, completion: nil)
            }
            else if named == "View/Edit Day-Time Preferences"{
                dayTimePrefPageFlag = 1
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TimeDayPref") as? TimeDayPrefViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                sideMenu?.dismiss(animated: true, completion: nil)
            }
            else if named == "Delete Account"{
                print("delete account clicked")
                self.showDeleteAccountConfirmAlert()
            }
            else if named == "Sign Out"{
                let firebaseAuth = Auth.auth()
                do{
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error Signing out- %@", signOutError)
                }
                print("view controllers stackkkkkkkkkkkkkkk", self.navigationController?.viewControllers)
                
                let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Navigator") as! LoginNavigationViewController
               UIApplication.shared.windows.first?.rootViewController = navigationController
               UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            else if named == "Close Settings"{
                let vcs = self.tabBarController?.viewControllers
                print(vcs)
                self.tabBarController?.selectedIndex = 2
                sideMenu?.dismiss(animated: true, completion: nil)
            }
        //})
    }
    
    func showDeleteAccountConfirmAlert(){
        sideMenu?.dismiss(animated: true, completion: nil)
        print("delete alert")
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure that you want to delete your account? Once deleted you will not be able to recover your account again.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [self] (_) in
            let user = Auth.auth().currentUser
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).delete()
            user?.delete { error in
              if let error = error {
                // An error happened.
              } else {
                let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Navigator") as! LoginNavigationViewController
               UIApplication.shared.windows.first?.rootViewController = navigationController
               UIApplication.shared.windows.first?.makeKeyAndVisible()
              }
            }
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        print("presenting")
        self.present(alertController, animated: true, completion: nil)
    }
    
    func animateIn(desiredView: UIView){
        let backgroundView = self.view!
        
        // Adding the desired view as subview
        backgroundView.addSubview(desiredView)
        
        // set scale to 120%
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        // animate the effect
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
            
        })
    }
    
    func animateOut(desiredView: UIView){
        
        // animate the effect
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
            
        }, completion: {_ in
            // Remove the subView
            desiredView.removeFromSuperview()
        })
    }
    
}

protocol MenuControllerDelegate{
    func didSelectMenuItem(named: String)
}

class MenuController: UITableViewController{
    
    public var delegate: MenuControllerDelegate?
    private let menuItems: [String]
    let menuSymbols = ["person.2", "square.and.pencil", "bell.badge", "ellipsis.bubble", "lock.rotation", "trash", "lock", "clear"]
    
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
        cell.textLabel?.font = .systemFont(ofSize: 18)
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

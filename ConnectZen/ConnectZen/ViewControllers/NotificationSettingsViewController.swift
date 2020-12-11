//
//  NotificationSettingsViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/8/20.
//

import UIKit
import Firebase
import EventKit

class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet weak var quotesSegControl: UISegmentedControl!
    @IBOutlet weak var meetupsCalSegControl: UISegmentedControl!
    @IBOutlet weak var calAccessSegControl: UISegmentedControl!
    let eventStore = EKEventStore()
    let db = Firestore.firestore()
    
    
    private func quoteUpdateView(){
        if quotesSegControl.selectedSegmentIndex == 0{ //NO
            removeQuotesNotifications()
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Quotes Enabled": false], merge: true)
            NotificationBanner.successShow("You will no longer be receiving daily motivational messages.")
        }else{
            scheduleQuotesNotification()
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Quotes Enabled": true], merge: true)
            NotificationBanner.successShow("Your daily motivational quotes have been setup.")
        }
    }
    private func meetupCalUpdateView(){
        if meetupsCalSegControl.selectedSegmentIndex == 0{ //NO
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": false], merge: true)
        }else{
            if self.checkCalendarAccess() == false{
                NotificationBanner.showFailure("To enable this you need to give calendar acess to ConnectZen")
                let status = self.getCalendarAccess()
                if status == true{
                    self.meetupsCalSegControl.selectedSegmentIndex = 1
                    self.calAccessSegControl.selectedSegmentIndex = 1
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": true], merge: true)
                }else{
                    self.meetupsCalSegControl.selectedSegmentIndex = 0
                }
            }else{
                print("iCal access already given")
                self.calAccessSegControl.selectedSegmentIndex = 1
                self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": true], merge: true)
            }
        }
    }
    private func calAccessUpdateView(){
        if self.calAccessSegControl.selectedSegmentIndex == 0{ //NO
            NotificationBanner.successShow("To revoke this permission please proceed to your phone settings to make the necessary changes.")
            self.meetupsCalSegControl.selectedSegmentIndex = 0
            self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": false], merge: true)
        }else{
            let status = self.getCalendarAccess()
            if status == false{
                self.calAccessSegControl.selectedSegmentIndex = 0
            }
        }
    }
    func getCalendarAccess() -> Bool{
        var status: Bool = false
        eventStore.requestAccess(to: .event, completion:
                                    {[weak self] (granted: Bool, error: Error?) -> Void in
                                        if granted {
                                            status = true
                                        }
                                    })
        return status
    }
    
    func checkCalendarAccess() -> Bool{
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    func askNotificationPermission(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if let error = error {
                // Handle the error here.
            }
            
            // Provisional authorization granted.
        }
    }
    func scheduleQuotesNotification(){
        askNotificationPermission()
        
        let calendar = Calendar.current
        print(Date())
        let range = calendar.range(of: .day, in: .month, for: Date())!
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        print(calendarDate)
        let numDays = range.count - calendarDate.day!
        print("numDays: ", numDays)
        //exit(20)
        self.db.collection("Quotes").document("startIdDocument").getDocument{ (doc, err) in
            if let doc = doc{
                let startID:Int = (doc["startID"] as? Int)!
                print(startID)
                
                self.db.collection("Quotes").order(by: "QuotesID").whereField("QuotesID", isGreaterThanOrEqualTo: startID).limit(to: numDays).getDocuments{(querySnapShot, error) in
                    if let error = error{
                        print("Error getting documents: \(error)")
                    }
                    else{
                        var NotifIds = Array<String>()
                        var date = 1
                        for doc in querySnapShot!.documents{
                            let content = UNMutableNotificationContent()
                            content.title = "Today's Quote"
                            content.body = ((doc["Title"] as? String)!) + "\n-" + ((doc["Author"] as? String)!)
                            
                            var dateComponents = DateComponents()
                            dateComponents.calendar = Calendar.current
                            
                            dateComponents.weekday = date // Tuesday
                            dateComponents.hour = 8    // 08:00 hours
                            
                            // Create the trigger as a repeating event.
                            let trigger = UNCalendarNotificationTrigger(
                                dateMatching: dateComponents, repeats: false)
                            
                            date += 1
                            
                            // Create the request
                            let uuidString = UUID().uuidString
                            NotifIds.append(uuidString)
                            print("New Notif ", uuidString)
                            let request = UNNotificationRequest(identifier: uuidString,
                                                                content: content, trigger: trigger)
                            
                            // Schedule the request with the system.
                            let notificationCenter = UNUserNotificationCenter.current()
                            notificationCenter.add(request) { (error) in
                                if error != nil {
                                    // Handle any errors.
                                }
                            }
                        }
                        // update startID
                        self.db.collection("Quotes").document("startIdDocument").updateData(["startID": startID + numDays], completion: {err in
                            if let err = err {
                                print("Error updating startID: \(err)")
                                //NotificationBanner.show("Failed to update meetup status, Please try again later!")
                            }
                            else{
                                // save notificationIDs
                                self.db.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["NotificationIDs": NotifIds], completion: {err in
                                    if let err = err {
                                        print("Error updating NotificationIDs: \(err)")
                                        //NotificationBanner.show("Failed to update meetup status, Please try again later!")
                                    }
                                    else{
                                        
                                    }
                                })
                            }
                        })
                    }
                    
                }
            }
            else{
                print("Error reading next QuoteID")
            }
            
        }
        
    }
    func removeQuotesNotifications(){
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc{
                let center = UNUserNotificationCenter.current()
                let NotificationIDs = doc["NotificationIDs"] as? [String]
                center.removePendingNotificationRequests(withIdentifiers: NotificationIDs!)
                // remove from firebase
                self.db.collection("Users").document(Auth.auth().currentUser!.uid).updateData([
                    "NotificationIDs": FieldValue.delete(),
                ]) { err in
                    if let err = err {
                        print("Error deleting NotificationIDs: \(err)")
                    }
                    else {
                        print("Document successfully deleted")
                    }
                }
            }
        }
    }
    
    
    @IBAction func quoteStatusChanged(_ sender: Any) {
        quoteUpdateView()
    }
    @IBAction func meetupCalStatusChanged(_ sender: Any) {
        meetupCalUpdateView()
    }
    @IBAction func calAccessStatusChanged(_ sender: Any) {
        calAccessUpdateView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 18)
        quotesSegControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        meetupsCalSegControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        calAccessSegControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        let status = self.checkCalendarAccess()
        print("iCal status ", status)
        if status == true{
            self.calAccessSegControl.selectedSegmentIndex = 1
        }else{
            self.calAccessSegControl.selectedSegmentIndex = 0
        }
    }
}

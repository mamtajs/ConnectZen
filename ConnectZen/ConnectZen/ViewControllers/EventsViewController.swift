//
//  EventsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/21/20.
//

import UIKit
import Firebase

class EventsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    @IBOutlet weak var EventType: UISegmentedControl!
    @IBOutlet weak var EventsTableView: UITableView!
    @IBOutlet var BlurView: UIVisualEffectView!
    @IBOutlet var OptionsViewUpcoming: UIView!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var DeleteMeetupButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet var OptionsViewPrevious: UIView!
    @IBOutlet weak var AbleToConnectSwitch: UISwitch!
    
    //let Upcoming :Array<Event>()
    var MeetupDatesTime = Dictionary<Date, Array<Array<Int>>>()
    var MeetupFriends = Array<String>()
    
    var listFriends = Dictionary<String , Array<String>>()
    var UpComingMeetings = Array<Event>()
    var PreviousMeetings = Array<Event>()
    var indexInData = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        EventsTableView.dataSource = self
        EventsTableView.delegate = self
        
        // setup other views after loading the view.
        BlurView.bounds = self.view.bounds
        OptionsViewUpcoming.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: self.view.bounds.height * 0.25)
        OptionsViewPrevious.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: self.view.bounds.height * 0.25)
        
        setupPopUpView(popUpView: OptionsViewUpcoming)
        setupPopUpView(popUpView: OptionsViewPrevious)
                
        Utilities.styleFilledButtonWithShadow(sendEmailButton)
        Utilities.styleFilledButtonWithShadow(sendMessageButton)
        Utilities.styleFilledButtonWithShadowDestructive(DeleteMeetupButton)
        
        initializeUpComingMeetings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let touch = touches.first
        if EventType.selectedSegmentIndex == 0 && touch?.view != self.OptionsViewUpcoming  {
            self.OptionsViewUpcoming.resignFirstResponder()
            self.animateOut(desiredView: OptionsViewUpcoming)
            self.animateOut(desiredView: BlurView)
        }
        else if EventType.selectedSegmentIndex == 1 && touch?.view != self.OptionsViewPrevious {
           self.OptionsViewPrevious.resignFirstResponder()
           self.animateOut(desiredView: OptionsViewPrevious)
           self.animateOut(desiredView: BlurView)
       }
        
    }
    
    func setupPopUpView(popUpView:UIView){
        popUpView.layer.cornerRadius = 10
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOpacity = 0.6
        popUpView.layer.shadowOffset = .zero
        popUpView.layer.shadowRadius = 6
        popUpView.layer.borderWidth = 2
        popUpView.layer.borderColor = UIColor.white.cgColor
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
    
    @IBAction func OptionsViewDismissButtonTapped(_ sender: Any) {
        self.OptionsViewUpcoming.resignFirstResponder()
        self.animateOut(desiredView: OptionsViewUpcoming)
        self.animateOut(desiredView: BlurView)
    }
    
    
    func getDateTime(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date{
        let calendar = Calendar.current

        var components = DateComponents()

        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "PST")
        //let date = calendar.date(from: components)!
       
        return calendar.date(from: components)!
    }
    
    func getNextMonth(today: Date) -> (Int, Int, Int){
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: today)
        let nextMonth = Calendar.current.component(.month, from: nextMonthDate!)
        let year = Calendar.current.component(.year, from: nextMonthDate!)
        // print(nextMonthDay, nextMonth)
        
        //let dateComponents = DateComponents(year: year, month: nextMonth)
        //let date =  Calendar.current.date(from: dateComponents)!

        let range = Calendar.current.range(of: .day, in: .month, for: nextMonthDate!)!
        
        let numDays = range.count
        print("Number of days in this month: ", numDays)
        
        return (nextMonth, year, numDays)
    }
    
    func initializeUpComingMeetings(){
        // Fetch events from firebase and initialize upcoming Meetups
        //let valuesNextMonth = getNextMonth(today: Date())
        //let nextMonth:Int = valuesNextMonth.0
        //let year:Int = valuesNextMonth.1
        //let lastDate:Int = valuesNextMonth.2
        
        let curDate:Int  = Calendar.current.component(.day, from: Date())
        let curMonth:Int = Calendar.current.component(.month, from: Date())
        let curYear:Int = Calendar.current.component(.year, from: Date())
        let curHour:Int = Calendar.current.component(.hour, from: Date())
        let curMinute:Int = Calendar.current.component(.minute, from: Date())
        
        print("Current Date: \(curDate)-\(curMonth)-\(curYear):\(curHour):\(curMinute)")
        //print(" Date: \(curDate)-\(curMonth)-\(curYear):\(curHour):\(curMinute)")
        let startTimeStamp = String(getDateTime(day: curDate, month: curMonth, year: curYear, hour: curHour, minute: curMinute).timeIntervalSince1970)
        //let endTimeStamp = String(getDateTime(day: lastDate, month: nextMonth, year: year, hour: 23, minute: 59).timeIntervalSince1970)
        //print("Before query", startTimeStamp)
        
        
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isGreaterThanOrEqualTo: startTimeStamp)
        query.getDocuments{(querySnapShot, error) in
            if let error = error{
                print("Error getting documents: \(error)")
            }
            else{
                var newEvent:Event = Event(TimeStamp: 0, Day: "", Date: "", StartTime: "", EndTime: "", FriendName:"", FriendPhoneNumber: "", FriendEmail: "", FriendID: "", MeetupHappened: false)
                var count = 0
                for document in querySnapShot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    newEvent.Day = document.data()["Day"] as! String
                    newEvent.Date = document.data()["Date"] as! String
                    newEvent.StartTime = document.data()["StartTime"] as! String
                    newEvent.EndTime = document.data()["EndTime"] as! String
                    newEvent.FriendPhoneNumber = document.data()["FriendPhoneNumber"] as! String
                    newEvent.MeetupHappened = document.data()["MeetupHappened"] as! String == "true"
                    //print(newEvent.Day, newEvent.Date , newEvent.StartTime, newEvent.EndTime, newEvent.FriendPhoneNumber, newEvent.MeetupHappened)
                    count += 1
                    
                    self.UpComingMeetings.append(newEvent)
                    
                }
                
                // Fetch friends data
                self.fetchFriendsData()
                
            }
        }
    }
    
    func fetchFriendsData(){
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid)
        query.getDocument{ [self](document, error) in
            if let document = document, document.exists{
                
                listFriends = document["Friends"] as! [String : [String]]
              
                // Map Friends
                var count = 0
                for meetup in self.UpComingMeetings{
                    UpComingMeetings[count].FriendName = listFriends[meetup.FriendPhoneNumber]![0]
                    UpComingMeetings[count].FriendEmail = listFriends[meetup.FriendPhoneNumber]![1]
                    UpComingMeetings[count].FriendID = listFriends[meetup.FriendPhoneNumber]![2]
                    count += 1
                }
                
                self.EventsTableView.reloadData()
                
                
                // Fetch events from firebase and initialize previous Meetups
                self.initializePreviousMeetings()
            }
            else{
                print("Document not found with user id \(Auth.auth().currentUser!.uid): Unregistered user")
            }
        }
        
    }
    
    // Fetch events from firebase and initialize previous Meetups
    func initializePreviousMeetings(){
        let curDate:Int  = Calendar.current.component(.day, from: Date())
        let curMonth:Int = Calendar.current.component(.month, from: Date())
        let curYear:Int = Calendar.current.component(.year, from: Date())
        let curHour:Int = Calendar.current.component(.hour, from: Date())
        let curMinute:Int = Calendar.current.component(.minute, from: Date())
        
        print("Current Date: \(curDate)-\(curMonth)-\(curYear):\(curHour):\(curMinute)")
       
        let startTimeStamp = String(getDateTime(day: curDate, month: curMonth, year: curYear, hour: curHour, minute: curMinute).timeIntervalSince1970)
    
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isLessThan: startTimeStamp)
        query.getDocuments{ [self](querySnapShot, error) in
            if let error = error{
                print("Error getting documents: \(error)")
            }
            else{
                var newEvent:Event = Event(TimeStamp: 0, Day: "", Date: "", StartTime: "", EndTime: "", FriendName:"", FriendPhoneNumber: "", FriendEmail: "", FriendID: "", MeetupHappened: false)
                var count = 0
                for document in querySnapShot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    newEvent.Day = document.data()["Day"] as! String
                    newEvent.Date = document.data()["Date"] as! String
                    newEvent.StartTime = document.data()["StartTime"] as! String
                    newEvent.EndTime = document.data()["EndTime"] as! String
                    newEvent.FriendPhoneNumber = document.data()["FriendPhoneNumber"] as! String
                    newEvent.MeetupHappened = document.data()["MeetupHappened"] as! String == "true"
                    //print(newEvent.Day, newEvent.Date , newEvent.StartTime, newEvent.EndTime, newEvent.FriendPhoneNumber, newEvent.MeetupHappened)
                    count += 1
                    
                    self.PreviousMeetings.append(newEvent)
                }
                
                // Map Friends
                count = 0
                for meetup in self.PreviousMeetings{
                    PreviousMeetings[count].FriendName = self.listFriends[meetup.FriendPhoneNumber]![0]
                    PreviousMeetings[count].FriendEmail = self.listFriends[meetup.FriendPhoneNumber]![1]
                    PreviousMeetings[count].FriendID = self.listFriends[meetup.FriendPhoneNumber]![2]
                    count += 1
                }
                
                self.EventsTableView.reloadData()
            }
        }
        //print("After query")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(EventType.selectedSegmentIndex == 0){ // Upcoming
            return UpComingMeetings.count
        }
        else{ // Previous
            return PreviousMeetings.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell") as! EventTableViewCell
        
        //cell.cellDelegate = self
        //print(indexPath)
        if(EventType.selectedSegmentIndex == 0){ // Upcoming
            cell.DayLabel.text = "\(UpComingMeetings[indexPath.row].Day), \(UpComingMeetings[indexPath.row].StartTime) - \(UpComingMeetings[indexPath.row].EndTime)"
            cell.NameLabel.text = "\(UpComingMeetings[indexPath.row].FriendName)"
            cell.DateLabel.text = "\(UpComingMeetings[indexPath.row].Date)"
            cell.editButton.tag = indexPath.row
            
            print(UpComingMeetings[indexPath.row].FriendPhoneNumber, UpComingMeetings[indexPath.row].FriendName, UpComingMeetings[indexPath.row].FriendEmail, UpComingMeetings[indexPath.row].FriendID)
        }
        else{
            cell.DayLabel.text = "\(PreviousMeetings[indexPath.row].Day), \(PreviousMeetings[indexPath.row].StartTime) - \(PreviousMeetings[indexPath.row].EndTime)"
            cell.NameLabel.text = "\(PreviousMeetings[indexPath.row].FriendName)"
            cell.DateLabel.text = "\(PreviousMeetings[indexPath.row].Date)"
            cell.editButton.tag = indexPath.row
            
            print(PreviousMeetings[indexPath.row].FriendPhoneNumber, PreviousMeetings[indexPath.row].FriendName, PreviousMeetings[indexPath.row].FriendEmail, PreviousMeetings[indexPath.row].FriendID)
        }
        
      
        cell.editButton.addTarget(self, action: #selector(self.EditButtonAction(_:)), for: .touchUpInside)
        cell.clipsToBounds = true
        return cell
    }
    
    @objc func EditButtonAction(_ sender: UIButton) {
        if(EventType.selectedSegmentIndex == 0){
            print("Upcoming Button Tapped", sender.tag)
            self.indexInData = sender.tag
            self.animateIn(desiredView: BlurView)
            self.animateIn(desiredView: OptionsViewUpcoming)
        }
        else{
            print("Previous Button Tapped", sender.tag)
            self.indexInData = sender.tag
            AbleToConnectSwitch.isOn = PreviousMeetings[indexInData].MeetupHappened
            self.animateIn(desiredView: BlurView)
            self.animateIn(desiredView: OptionsViewPrevious)
        }
    }
    
    @IBAction func PreviousOptionsViewDismiss(_ sender: Any) {
        self.OptionsViewPrevious.resignFirstResponder()
        self.animateOut(desiredView: OptionsViewPrevious)
        self.animateOut(desiredView: BlurView)
    }
    
    @IBAction func AbleToConnectSwitchToggled(_ sender: Any) {
        PreviousMeetings[indexInData].MeetupHappened = AbleToConnectSwitch.isOn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // your code
        print("Row tapped", indexPath)
    }
    
    @IBAction func SegmentChanged(_ sender: Any) {
        //print("Segment ",EventType.selectedSegmentIndex)
        
        if(EventType.selectedSegmentIndex == 0){ // Upcoming
            EventsTableView.reloadData()
        }
        else{ // Previous
            EventsTableView.reloadData()
        }
    }
    
    
}

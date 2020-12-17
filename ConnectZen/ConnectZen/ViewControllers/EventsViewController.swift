//
//  EventsViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/21/20.
//

import UIKit
import Firebase
import MessageUI
import EventKit
import EventKitUI

enum popUpType{
    case OptionsForUpcoming
    case OptionsForPrevious
    case EditEvent
    case None
}

class EventsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    let db = Firestore.firestore()
    @IBOutlet weak var EventType: UISegmentedControl!
    @IBOutlet weak var EventsTableView: UITableView!
    @IBOutlet var BlurView: UIVisualEffectView!
    @IBOutlet var OptionsViewUpcoming: UIView!
    @IBOutlet var EditEventView: UIView!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var DeleteMeetupButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var EditEventButton: UIButton!
    @IBOutlet weak var SaveChangesButton: UIButton!
    
    @IBOutlet var OptionsViewPrevious: UIView!
    @IBOutlet weak var AbleToConnectSegment: UISegmentedControl!
    
    //let Upcoming :Array<Event>()
    var MeetupDatesTime = Dictionary<Date, Array<Array<Int>>>()
    var MeetupFriends = Array<String>()
    
    var listFriends = Dictionary<String , Array<String>>()
    var createCalendarEvents:Bool = false
    var allFriends = Array<Person>()
    var EventDates = Set<String>()
    var UpComingMeetings = Array<Event>()
    var PreviousMeetings = Array<Event>()
    var indexInData:Int = 0
    var curPopUp:popUpType = .None
    @IBOutlet weak var FriendEditEventView: UIPickerView!
    var selectedFriendIndex:Int = 0
    @IBOutlet weak var StartTimeEditEventView: UIDatePicker!
    @IBOutlet weak var EndTimeEditEventView: UIDatePicker!
    
    var startTime24HrPrev:Time = Time(Hour: 0, Minute: 0)
    var endTime24HrPrev:Time = Time(Hour: 0, Minute: 0)
    var startTime24Hr:Time = Time(Hour: 0, Minute: 0)
    var endTime24Hr:Time = Time(Hour: 0, Minute: 0)
    var rowToSelectForPickerView:[Int] = [0, 0]
    var someDataUpdatedInEvent:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 18)
        EventType.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        AbleToConnectSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        EventsTableView.dataSource = self
        EventsTableView.delegate = self
        FriendEditEventView.delegate = self
        FriendEditEventView.dataSource = self
        
        //initializeUpComingMeetings()
        
        // setup other views after loading the view.
        BlurView.bounds = self.view.bounds
        // BlurView.backgroundColor = UIColor.init(red: 8/255, green: 232/255, blue: 222/255, alpha: 0.2)
        BlurView.alpha = 0.005
        BlurView.overrideUserInterfaceStyle = .light
        
        OptionsViewUpcoming.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.3)
        OptionsViewPrevious.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.3)
        EditEventView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.35)
        
        setupPopUpView(popUpView: OptionsViewUpcoming)
        setupPopUpView(popUpView: OptionsViewPrevious)
        setupPopUpView(popUpView: OptionsViewPrevious)
        setupPopUpView(popUpView: EditEventView)
        
        
        Utilities.styleFilledButtonWithShadow(sendEmailButton)
        Utilities.styleFilledButtonWithShadow(sendMessageButton)
        Utilities.styleFilledButtonWithShadow(EditEventButton)
        Utilities.styleFilledButtonWithShadow(SaveChangesButton)
        StartTimeEditEventView.preferredDatePickerStyle = .inline
        EndTimeEditEventView.preferredDatePickerStyle = .inline
        Utilities.styleFilledButtonWithShadowDestructive(DeleteMeetupButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        settingsIndex = 3
        self.navigationController?.navigationBar.topItem?.title  = "Scheduled Meetings"
        EventType.selectedSegmentIndex = 0
        UpComingMeetings.removeAll()
        PreviousMeetings.removeAll()
        EventDates.removeAll()
        initializeUpComingMeetings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        switch(self.curPopUp){
        case .OptionsForUpcoming:
            if(touch?.view != self.OptionsViewUpcoming){
                self.OptionsViewUpcoming.resignFirstResponder()
                self.animateOut(desiredView: OptionsViewUpcoming)
                self.animateOut(desiredView: BlurView)
                self.curPopUp = .None
            }
        case .OptionsForPrevious:
            if(touch?.view != self.OptionsViewPrevious){
                self.OptionsViewPrevious.resignFirstResponder()
                self.animateOut(desiredView: OptionsViewPrevious)
                self.animateOut(desiredView: BlurView)
                self.curPopUp = .None
            }
        case .EditEvent:
            if(touch?.view != self.EditEventView){
                self.EditEventView.resignFirstResponder()
                self.animateOut(desiredView: EditEventView)
                self.animateOut(desiredView: BlurView)
                self.curPopUp = .None
            }
        case .None:
            self.curPopUp = .None
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
        self.curPopUp = .None
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
    
    func get12HourTimeString(hour:Int, minute:Int) -> String{
        var PM:Bool = false
        var newhour = hour
        
        if(newhour > 12){
            newhour -= 12
            PM = true
        }
        else if(newhour == 12){
            PM = true
        }
        else if(newhour  == 0){
            newhour = 12
        }
        
        var timeString = ""
        if(newhour < 10){
            timeString += "0"
        }
        
        timeString += String(newhour) + ":"
        
        if(minute < 10){
            timeString += "0"
        }
        timeString += String(minute)
        
        if(PM){
            timeString += " PM"
        }
        else{
            timeString += " AM"
        }
        
        return timeString
    }
    
    func convertTo24HourFormatDate(time: String) -> Date{
        let splitOne = time.split(separator: ":")
        var hour = Int(splitOne[0])
        let splitTwo = splitOne[1].split(separator: " ")
        let minute = Int(splitTwo[0])
        let timePeriod = splitTwo[1]
        
        if(timePeriod.contains("PM") && hour != 12){
            hour = hour! + 12
        }else if(timePeriod.contains("AM") && hour == 12){
            hour = 0
        }
        
        return getDateTime(day: 1, month: 1, year: 2020, hour: hour!, minute: minute!)
    }
    
    func getInt24HrHourMinuteFrom12HrFormatString(time: String) -> Array<Int>{
        let splitOne = time.split(separator: ":")
        var hour = Int(splitOne[0])
        let splitTwo = splitOne[1].split(separator: " ")
        let minute = Int(splitTwo[0])
        let timePeriod = splitTwo[1]
        
        if(timePeriod.contains("PM") && hour != 12){
            hour = hour! + 12
        }else if(timePeriod.contains("AM") && hour == 12){
            hour = 0
        }
        
        return [hour!, minute!]
    }
    
    func compareTime(hour1:Int, minute1:Int, hour2:Int, minute2:Int) -> Int{ // return 1 when firstTime>secondTime return -1 when secondTime>firstTime 11>10 else 0
        if(hour1 > hour2){
            return 1
        }
        else if(hour1 < hour2){
            return -1
        }
        else{ //hou1 == hour2
            if(minute1 > minute2){
                return 1
            }
            else if(minute1 < minute2){
                return -1
            }
        }
        
        return 0
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
        
        // Change 1640851200 to startTimeStamp
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isGreaterThanOrEqualTo: startTimeStamp)
        query.getDocuments{(querySnapShot, error) in
            if let error = error{
                print("Error getting documents: \(error)")
            }
            else{
                var newEvent:Event = Event(TimeStamp: 0, Day: "", Date: "", StartTime: "", EndTime: "", FriendName:"", FriendPhoneNumber: "", FriendEmail: "", FriendID: "", MeetupHappened: false, documentID: "", calendarEventID: "")
                var count = 0
                print("Got UpComing Meetups in Events")
                for document in querySnapShot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    newEvent.Day = document.data()["Day"] as! String
                    newEvent.Date = document.data()["Date"] as! String
                    newEvent.StartTime = document.data()["StartTime"] as! String
                    newEvent.EndTime = document.data()["EndTime"] as! String
                    newEvent.FriendPhoneNumber = document.data()["FriendPhoneNumber"] as! String
                    newEvent.MeetupHappened = document.data()["MeetupHappened"] as! String == "true"
                    //print(newEvent.Day, newEvent.Date , newEvent.StartTime, newEvent.EndTime, newEvent.FriendPhoneNumber, newEvent.MeetupHappened)
                    newEvent.documentID = document.documentID
                    newEvent.calendarEventID = document.data()["CalendarEventID"] as? String ?? ""
                    count += 1
                    
                    if(!self.EventDates.contains(newEvent.Date)){
                        self.UpComingMeetings.append(newEvent)
                        self.EventDates.insert(newEvent.Date)
                    }
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
                
                self.listFriends = document["Friends"] as? [String : [String]] ?? self.listFriends
                self.createCalendarEvents = document["Calendar Updation Access"] as? Bool ?? false
                
                // Map Friends
                var count = 0
                for meetup in self.UpComingMeetings{
                    UpComingMeetings[count].FriendName = listFriends[meetup.FriendPhoneNumber]![0]
                    UpComingMeetings[count].FriendEmail = listFriends[meetup.FriendPhoneNumber]![1]
                    UpComingMeetings[count].FriendID = listFriends[meetup.FriendPhoneNumber]![2]
                    count += 1
                }
                
                self.EventsTableView.reloadData()
                
                self.allFriends.removeAll()
                for friend in listFriends{
                    let newVal = Person(contactName: friend.value[0], PhoneNumber: friend.key)
                    listFriends[newVal.PhoneNumber]?.append(String(allFriends.count))
                    allFriends.append(newVal)
                }
                
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
                var newEvent:Event = Event(TimeStamp: 0, Day: "", Date: "", StartTime: "", EndTime: "", FriendName:"", FriendPhoneNumber: "", FriendEmail: "", FriendID: "", MeetupHappened: false, documentID: "", calendarEventID: "")
                var count = 0
                print("Got Previous Meetups in Events")
                for document in querySnapShot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    newEvent.Day = document.data()["Day"] as! String
                    newEvent.Date = document.data()["Date"] as! String
                    newEvent.StartTime = document.data()["StartTime"] as! String
                    newEvent.EndTime = document.data()["EndTime"] as! String
                    newEvent.FriendPhoneNumber = document.data()["FriendPhoneNumber"] as! String
                    newEvent.MeetupHappened = document.data()["MeetupHappened"] as! String == "true"
                    //print(newEvent.Day, newEvent.Date , newEvent.StartTime, newEvent.EndTime, newEvent.FriendPhoneNumber, newEvent.MeetupHappened)
                    newEvent.documentID = document.documentID
                    newEvent.calendarEventID = document.data()["CalendarEventID"] as? String ?? ""
                    count += 1
                    
                    if(!EventDates.contains(newEvent.Date)){
                        self.PreviousMeetings.append(newEvent)
                        EventDates.insert(newEvent.Date)
                    }
                    
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
            cell.DayLabel.text = "\(UpComingMeetings[indexPath.row].Day), \(UpComingMeetings[indexPath.row].StartTime)-\(UpComingMeetings[indexPath.row].EndTime)"
            cell.NameLabel.text = "\(UpComingMeetings[indexPath.row].FriendName)"
            cell.DateLabel.text = "\(UpComingMeetings[indexPath.row].Date)"
            cell.editButton.tag = indexPath.row
            
            print(UpComingMeetings[indexPath.row].FriendPhoneNumber, UpComingMeetings[indexPath.row].FriendName, UpComingMeetings[indexPath.row].FriendEmail, UpComingMeetings[indexPath.row].FriendID)
        }
        else{
            let actualIndex = PreviousMeetings.count - 1 - indexPath.row
            cell.DayLabel.text = "\(PreviousMeetings[actualIndex].Day), \(PreviousMeetings[actualIndex].StartTime) - \(PreviousMeetings[actualIndex].EndTime)"
            cell.NameLabel.text = "\(PreviousMeetings[actualIndex].FriendName)"
            cell.DateLabel.text = "\(PreviousMeetings[actualIndex].Date)"
            cell.editButton.tag = actualIndex
            
            print(PreviousMeetings[actualIndex].FriendPhoneNumber, PreviousMeetings[actualIndex].FriendName, PreviousMeetings[actualIndex].FriendEmail, PreviousMeetings[actualIndex].FriendID)
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
            self.curPopUp = .OptionsForUpcoming
        }
        else{
            print("Previous Button Tapped", sender.tag)
            self.indexInData = sender.tag
            AbleToConnectSegment.selectedSegmentIndex = PreviousMeetings[indexInData].MeetupHappened ? 1 : 0
            // AbleToConnectSwitch.isOn = PreviousMeetings[indexInData].MeetupHappened
            self.animateIn(desiredView: BlurView)
            self.animateIn(desiredView: OptionsViewPrevious)
            self.curPopUp = .OptionsForPrevious
        }
    }
    
    @IBAction func PreviousOptionsViewDismiss(_ sender: Any) {
        self.OptionsViewPrevious.resignFirstResponder()
        self.animateOut(desiredView: OptionsViewPrevious)
        self.animateOut(desiredView: BlurView)
        self.curPopUp = .None
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
    
    
    @IBAction func RemindByEmailTapped(_ sender: Any) {
        self.OptionsViewUpcoming.resignFirstResponder()
        self.animateOut(desiredView: self.OptionsViewUpcoming)
        self.animateOut(desiredView: self.BlurView)
        self.curPopUp = .None
        
        guard MFMailComposeViewController.canSendMail() else{
            // show error to user and return
            print("Device doesn't support email")
            NotificationBanner.showFailure("Please setup \"Mail\" application on your device to enable this feature.")
            return
        }
        
        let composer  = MFMailComposeViewController()
        composer.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
        composer.setToRecipients([UpComingMeetings[indexInData].FriendEmail])
        composer.setSubject("Let's Catchup on \(UpComingMeetings[indexInData].Date)")
        let message = "Hello \(UpComingMeetings[indexInData].FriendName), \nIt's been a while since we talked. How does connecting on \(UpComingMeetings[indexInData].Date)(\(UpComingMeetings[indexInData].Day)) from \(UpComingMeetings[indexInData].StartTime) to \(UpComingMeetings[indexInData].EndTime) sound to you? Hope to see you soon!\n"
        composer.setMessageBody(message, isHTML: false)
        present(composer, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            // show error alert233
            controller.dismiss(animated: true)
            NotificationBanner.showFailure("Error occured while sending email, please try again later!")
        }
        
        controller.dismiss(animated: true)
        
        switch result{
        //case .cancelled:
          //  NotificationBanner.show("Email cancelled")
        case .failed:
            NotificationBanner.showFailure("Email failed to send, please try again later!")
        //case .saved:
         //   NotificationBanner.show("Email saved!")
        case .sent:
            NotificationBanner.successShow("Reminder email sent!")
        @unknown default:
            print("Email cancelled or saved or default")
        }
        
    }
    
    @IBAction func RemindByMessageTapped(_ sender: Any) {
        self.OptionsViewUpcoming.resignFirstResponder()
        self.animateOut(desiredView: OptionsViewUpcoming)
        self.animateOut(desiredView: BlurView)
        self.curPopUp = .None
        
        if(MFMessageComposeViewController.canSendText()) {
            
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self as MFMessageComposeViewControllerDelegate
            
            controller.body = "Hello \(UpComingMeetings[indexInData].FriendName), \nIt's been a while since we talked. How does connecting on \(UpComingMeetings[indexInData].Date)(\(UpComingMeetings[indexInData].Day)) from \(UpComingMeetings[indexInData].StartTime) to \(UpComingMeetings[indexInData].EndTime) sound to you? Hope to see you soon!\n"
            controller.recipients = [UpComingMeetings[indexInData].FriendPhoneNumber] //Here goes whom you wants to send the message
            
            self.present(controller, animated: true)
        }
        //This is just for testing purpose as when you run in the simulator, you cannot send the message.
        else{
            NotificationBanner.showFailure("Please setup \"Messages\" application on your device to enable this feature.")
            print("Cannot send the message: not supported on device!")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        //Displaying the message screen with animation.
        self.dismiss(animated: true, completion: nil)
        switch result {
        //case .cancelled:
            //NotificationBanner.show("Message cancelled!")
        case .sent:
            NotificationBanner.successShow("Reminder message sent!")
        case .failed:
            NotificationBanner.showFailure("Failed to send message, Please try again later!")
        default:
            print("Default in message sending")
        }
        
    }
    
    @IBAction func DeleteMeetupTapped(_ sender: Any) {
        self.OptionsViewUpcoming.resignFirstResponder()
        self.animateOut(desiredView: OptionsViewUpcoming)
        self.animateOut(desiredView: BlurView)
        self.curPopUp = .None
        
        // Ask confirmation in alert
        let alert = UIAlertController(title: "Confirm", message: "Do you want to cancel the meetup with \(UpComingMeetings[indexInData].FriendName) on \(UpComingMeetings[indexInData].Date)(\(UpComingMeetings[indexInData].Day)) from \(UpComingMeetings[indexInData].StartTime) to \(UpComingMeetings[indexInData].EndTime)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self]_ in
            // remove from firebase
            //db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).getDocument{ (doc,err) in
                //if let doc = doc{
                    let calendarEventID = self.UpComingMeetings[self.indexInData].calendarEventID
                    if(calendarEventID != ""){
                        // delete this event from calendar
                        CalendarFunctions().removeCalendarEvent(store: EKEventStore(), withIdentifier: calendarEventID)
                    }
                    
                    // Delete meetup
                    db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                            NotificationBanner.showFailure("Failed to delete meetup, Please try again later!")
                        }
                        else {
                            print("Document successfully removed!")
                            self.UpComingMeetings.remove(at: self.indexInData)
                            NotificationBanner.showWithColor("Successfully removed meetup!", UIColor(red: 0, green: 102/255, blue: 0, alpha: 1), UIColor.white)
                            self.EventsTableView.reloadData()
                        }
                    }
                //}
            //}
        
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func AbleToConnectSegmentChanged(_ sender: Any) {
        var toSave = ""
        if (AbleToConnectSegment.selectedSegmentIndex == 0){
            toSave = "false"
        }
        else{
            toSave =  "true"
        }
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.PreviousMeetings[self.indexInData].documentID).updateData(["MeetupHappened": toSave], completion: {err in
            if let err = err {
                print("Error updating document: \(err)")
                NotificationBanner.showFailure("Failed to update meetup status, Please try again later!")
            }
            else{
                self.PreviousMeetings[self.indexInData].MeetupHappened = (self.AbleToConnectSegment.selectedSegmentIndex == 1)
                
                self.OptionsViewPrevious.resignFirstResponder()
                self.animateOut(desiredView: self.OptionsViewPrevious)
                self.animateOut(desiredView: self.BlurView)
                self.curPopUp = .None
                
                NotificationBanner.showWithColor("Successfully updated meetup status!", UIColor(red: 0, green: 102/255, blue: 0, alpha: 1), UIColor.white)
                self.EventsTableView.reloadData()
            }
            
        })
        
    }
    
    @IBAction func EditEvent(_ sender: Any) {
        self.OptionsViewUpcoming.resignFirstResponder()
        self.animateOut(desiredView: self.OptionsViewUpcoming)
        
        self.someDataUpdatedInEvent = false
        self.rowToSelectForPickerView[0] = Int(listFriends[UpComingMeetings[indexInData].FriendPhoneNumber]![3])!
        self.rowToSelectForPickerView[1] = self.rowToSelectForPickerView[0]
        
        self.FriendEditEventView.selectRow(rowToSelectForPickerView[0], inComponent: 0, animated: true)
        
        self.StartTimeEditEventView.setDate(convertTo24HourFormatDate(time: UpComingMeetings[indexInData].StartTime), animated: true)
        var hrMin = getInt24HrHourMinuteFrom12HrFormatString(time: UpComingMeetings[indexInData].StartTime)
        self.startTime24HrPrev.Hour = hrMin[0]
        self.startTime24HrPrev.Minute = hrMin[1]
        self.startTime24Hr.Hour = self.startTime24HrPrev.Hour
        self.startTime24Hr.Minute = self.startTime24HrPrev.Minute
        
        self.EndTimeEditEventView.setDate(convertTo24HourFormatDate(time: UpComingMeetings[indexInData].EndTime), animated: true)
        hrMin = getInt24HrHourMinuteFrom12HrFormatString(time: UpComingMeetings[indexInData].EndTime)
        self.endTime24HrPrev.Hour = hrMin[0]
        self.endTime24HrPrev.Minute = hrMin[1]
        self.endTime24Hr.Hour = self.endTime24HrPrev.Hour
        self.endTime24Hr.Minute = self.endTime24HrPrev.Minute
        
        self.animateIn(desiredView: self.EditEventView)
        self.curPopUp = .EditEvent
    }
    
    @IBAction func dismissEditEventView(_ sender: Any) {
        self.EditEventView.resignFirstResponder()
        self.animateOut(desiredView: self.EditEventView)
        self.animateOut(desiredView: self.BlurView)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allFriends.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allFriends[row].contactName
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        //let newRow:Int = pickerView.selectedRow(inComponent: component)
        self.rowToSelectForPickerView[1] = pickerView.selectedRow(inComponent: component)
        /*db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["FriendPhoneNumber": self.allFriends[newRow].PhoneNumber], completion: {err in
         if let err = err {
         print("Error updating document: \(err)")
         NotificationBanner.show("Failed to update event, Please try again later!")
         }
         else{
         self.UpComingMeetings[self.indexInData].FriendPhoneNumber = self.allFriends[newRow].PhoneNumber
         self.UpComingMeetings[self.indexInData].FriendName = (self.listFriends[self.allFriends[newRow].PhoneNumber]?[0])!
         self.UpComingMeetings[self.indexInData].FriendEmail = (self.listFriends[self.allFriends[newRow].PhoneNumber]?[1])!
         self.UpComingMeetings[self.indexInData].FriendID = (self.listFriends[self.allFriends[newRow].PhoneNumber]?[2])!
         
         //NotificationBanner.show("Successfully updated event!")
         
         self.EventsTableView.reloadData()
         }
         })*/
    }
    
    @IBAction func StartTimeChanged(_ sender: UIDatePicker) {
        //print(sender.date)
        
        self.startTime24Hr.Hour = Calendar.current.component(.hour, from: sender.date)
        self.startTime24Hr.Minute = Calendar.current.component(.minute, from: sender.date)
        
        /*
         let newTimeString = get12HourTimeString(hour: startTime24Hr.Hour, minute: startTime24Hr.Minute)
         print("Start Time: ", newTimeString)
         
         db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["StartTime": newTimeString], completion: {err in
         if let err = err {
         print("Error updating document: \(err)")
         NotificationBanner.show("Failed to update event, Please try again later!")
         }
         else{
         self.UpComingMeetings[self.indexInData].StartTime = newTimeString
         
         self.EventsTableView.reloadData()
         }
         })*/
        
    }
    
    @IBAction func EndTimeChanged(_ sender: UIDatePicker) {
        
        self.endTime24Hr.Hour = Calendar.current.component(.hour, from: sender.date)
        self.endTime24Hr.Minute = Calendar.current.component(.minute, from: sender.date)
        
        /* let curHour:Int = Calendar.current.component(.hour, from: sender.date)
         let curMinute:Int = Calendar.current.component(.minute, from: sender.date)
         
         let newTimeString = get12HourTimeString(hour: curHour, minute: curMinute)
         print("End Time: ", newTimeString)
         
         db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["EndTime": newTimeString], completion: {err in
         if let err = err {
         print("Error updating document: \(err)")
         NotificationBanner.show("Failed to update event, Please try again later!")
         }
         else{
         self.UpComingMeetings[self.indexInData].EndTime = newTimeString
         
         self.EventsTableView.reloadData()
         }
         })*/
    }
    
    @IBAction func SaveChangesButtonTapped(_ sender: Any) {
        
        // If pickerView row has changed then update the contact
        if(self.rowToSelectForPickerView[0] != self.rowToSelectForPickerView[1]){
            db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["FriendPhoneNumber": self.allFriends[self.rowToSelectForPickerView[1]].PhoneNumber], completion: {err in
                if let err = err {
                    print("Error updating document: \(err)")
                    NotificationBanner.showFailure("Failed to update event, Please try again later!")
                }
                else{
                    self.someDataUpdatedInEvent = true
                    self.UpComingMeetings[self.indexInData].FriendPhoneNumber = self.allFriends[self.rowToSelectForPickerView[1]].PhoneNumber
                    self.UpComingMeetings[self.indexInData].FriendName = (self.listFriends[self.allFriends[self.rowToSelectForPickerView[1]].PhoneNumber]?[0])!
                    self.UpComingMeetings[self.indexInData].FriendEmail = (self.listFriends[self.allFriends[self.rowToSelectForPickerView[1]].PhoneNumber]?[1])!
                    self.UpComingMeetings[self.indexInData].FriendID = (self.listFriends[self.allFriends[self.rowToSelectForPickerView[1]].PhoneNumber]?[2])!
                    
                    self.checkAndUpdateTime()
                    
                }
            })
        }
        else{
            self.checkAndUpdateTime()
        }
        
    }
    
    func checkAndUpdateTime(){
        // Check if startTime has changed if so update it, is less than endTime if not then show error
        
        if(compareTime(hour1: startTime24Hr.Hour, minute1: startTime24Hr.Minute, hour2: endTime24Hr.Hour, minute2: endTime24Hr.Minute) >= 0){
            NotificationBanner.showFailure("Start time of event can not be greater than or equal to the end time, please correct and try again!")
        }
        else{
            // if startTime is changed
            if(startTime24Hr.Hour != startTime24HrPrev.Hour || startTime24HrPrev.Minute != startTime24Hr.Minute){
                let newTimeString = get12HourTimeString(hour: startTime24Hr.Hour, minute: startTime24Hr.Minute)
                print("Start Time: ", newTimeString)
                
                db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["StartTime": newTimeString], completion: {err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        NotificationBanner.showFailure("Failed to update event, Please try again later!")
                    }
                    else{
                        self.someDataUpdatedInEvent = true
                        self.UpComingMeetings[self.indexInData].StartTime = newTimeString
                        self.checkAndUpdateEndTime()
                        
                    }
                })
            }
            else{
                self.checkAndUpdateEndTime()
            }
            
        }
    }
    
    func checkAndUpdateEndTime(){
        if(endTime24Hr.Hour != endTime24HrPrev.Hour || endTime24Hr.Minute != endTime24HrPrev.Minute){
            let newTimeString = get12HourTimeString(hour: endTime24Hr.Hour, minute: endTime24Hr.Minute)
            print("End Time: ", newTimeString)
            
            db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["EndTime": newTimeString], completion: {err in
                if let err = err {
                    print("Error updating document: \(err)")
                    NotificationBanner.showFailure("Failed to update event, Please try again later!")
                }
                else{
                    self.someDataUpdatedInEvent = true
                    self.UpComingMeetings[self.indexInData].EndTime = newTimeString
                    
                    self.checkIfUpdatedAndReload()
                }
            })
        }
        else{
            self.checkIfUpdatedAndReload()
        }
    }
    
    func checkIfUpdatedAndReload(){
        if(self.someDataUpdatedInEvent){
           
            let eventStore = EKEventStore()
            let cf:CalendarFunctions = CalendarFunctions()
            if(self.createCalendarEvents && cf.checkCalendarAccess()){  // if user wants calendar events and we have access to iCal
                
                // delete prior calendar event
                let calendarEventID = self.UpComingMeetings[self.indexInData].calendarEventID
                if(calendarEventID != ""){
                    // delete this event from calendar
                    CalendarFunctions().removeCalendarEvent(store: EKEventStore(), withIdentifier: calendarEventID)
                }
                
                // insert calendar event
                let meetupDate:Date = cf.getDateFromString(dateString: UpComingMeetings[self.indexInData].Date, dateFormat: "dd MMMM yyyy")
                
                let durationOfMeetup = (endTime24Hr.Hour - startTime24Hr.Hour)*60 - startTime24Hr.Minute + endTime24Hr.Minute
                let newCalendarEventID = cf.createCalendarEvent(store: eventStore, date: meetupDate, HourMin: [startTime24Hr.Hour, startTime24Hr.Minute], durationOfMeetup: durationOfMeetup, friendName: self.UpComingMeetings[self.indexInData].FriendName)
                self.UpComingMeetings[self.indexInData].calendarEventID = newCalendarEventID ?? ""
                
                // update calendar event ID on firebase
                db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document(self.UpComingMeetings[self.indexInData].documentID).updateData(["CalendarEventID": newCalendarEventID ?? ""], completion: {err in
                    if let err = err {
                        print("Error calendar event: \(err)")
                        //NotificationBanner.show("Failed to update event, Please try again later!")
                        self.EventsTableView.reloadData()
                        self.EditEventView.resignFirstResponder()
                        self.animateOut(desiredView: self.EditEventView)
                        self.animateOut(desiredView: self.BlurView)
                    }
                    else{
                        NotificationBanner.showWithColor("Event updated successfully!", UIColor(red: 0, green: 102/255, blue: 0, alpha: 1), UIColor.white)
                        self.EventsTableView.reloadData()
                        self.EditEventView.resignFirstResponder()
                        self.animateOut(desiredView: self.EditEventView)
                        self.animateOut(desiredView: self.BlurView)
                    }
                })
               
            }
            else{
                NotificationBanner.showWithColor("Event updated successfully!", UIColor(red: 0, green: 102/255, blue: 0, alpha: 1), UIColor.white)
                self.EventsTableView.reloadData()
                self.EditEventView.resignFirstResponder()
                self.animateOut(desiredView: self.EditEventView)
                self.animateOut(desiredView: self.BlurView)
            }
        }
    }
}

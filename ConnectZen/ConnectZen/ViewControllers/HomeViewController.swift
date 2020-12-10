//
//  HomeViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/8/20.
//

import UIKit
import Firebase
import FirebaseUI
import EventKit

class HomeViewController: UIViewController {

    let db = Firestore.firestore()
    @IBOutlet var popUpView: UIView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet weak var SchedulingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var schedButton: UIButton!
    @IBOutlet weak var ScheduleMeetingsButton: UIButton!
    
    // User preferences for schedule meetups
    var durationOfMeetup:Int = 10 // minutes
    var numOfMeetupsPerMonth:Int = 5 // people
    var prefDayTime =  Dictionary<String, Dictionary<String, String>>() // Day -> {StartTime-> EndTime, ....}
    var createCalendarEvents:Bool = false
    
    let meetupDefaultStartTime:String = "09:00"
    let meetupDefaultEndTime:String = "21:00"
    var listFriends = Dictionary<String, Array<String>>() //: Array<Person> = []   // All friends excluding past 1 months meetups
    var MeetupDatesTime = Dictionary<Date, Array<Array<Int>>>()
    var MeetupFriends = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup other views after loading the view.
        blurView.bounds = self.view.bounds
        schedButton.layer.cornerRadius = 10
        popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.4)
        Utilities.styleFilledButton(ScheduleMeetingsButton)
        
        setupPopUpView(popUpView: popUpView)
        
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
        
        let valuesNextMonth = getNextMonth(today: Date())
        let nextMonth: Int = valuesNextMonth.0
        let year: Int = valuesNextMonth.1
        let numDays = getDaysInNextMonth(nextMonth: nextMonth, year: year)
        print("numDays: ", numDays)
        
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
    
    /*func removeQuotesNotifications(){
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc{
                let center = UNUserNotificationCenter.current()
                let NotificationIDs = doc["NotificationIDs"] as? [String]
                if(NotificationIDs != nil){
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
    }*/
    
    @IBAction func scheduleButtonTapped(_ sender: Any) {
        // Start scheduling Meetups only if it is not already done for the next month
        var nextMonthEventsScheduled = false
        
        let valuesNextMonth = getNextMonth(today: Date())
        let nextMonth: Int = valuesNextMonth.0
        let year: Int = valuesNextMonth.1
        let startTimeStamp = String(getDateTime(day: 1, month: nextMonth, year: year, hour: 0, minute: 0).timeIntervalSince1970)
        
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isGreaterThanOrEqualTo: startTimeStamp)
        query.getDocuments{(querySnapShot, error) in
            if let error = error{
                print("Error getting documents: \(error)")
                
            }
            else{
                let count = querySnapShot!.documents.count
                nextMonthEventsScheduled = (count != 0)
                
                if(!nextMonthEventsScheduled){
                    // Show popUp and start Activity indicator
                    self.animateIn(desiredView: self.blurView)
                    self.animateIn(desiredView: self.popUpView)
                    self.SchedulingActivityIndicator.startAnimating()
                    
                    self.loadFromFirebase()
                    
                }
                else{
                    NotificationBanner.show("All your Meetups for the nextmonth are already scheduled! Checkout your scheduled Meetups page.")
                    
                }
            }
        }
        
    }
    
    func loadFromFirebase(){
        
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid)
        query.getDocument{(document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Duration", document["Preferred Duration"] as String)
                print(dataDescription)
                
                self.durationOfMeetup = document["Preferred Duration"] as! Int
                self.numOfMeetupsPerMonth = document["Preferred Frequency"] as! Int
                if(document["Day and Time Preferences"] != nil){
                    self.prefDayTime =  document["Day and Time Preferences"] as! [String : [String : String]]
                }
                self.listFriends = document["Friends"] as! [String : [String]]
                self.createCalendarEvents = document["Calendar Updation Access"] as! Bool
                
                // Schedule events
                self.scheduleEvents()
                
                // Hide popUp
                self.SchedulingActivityIndicator.stopAnimating()
                self.animateOut(desiredView: self.popUpView)
                self.animateOut(desiredView: self.blurView)
                
                // Show Scheduled Events page
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EventsVC") as? EventsViewController
                vc?.MeetupDatesTime = self.MeetupDatesTime
                vc?.MeetupFriends = self.MeetupFriends
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else{
                print("Document not found")
                self.SchedulingActivityIndicator.stopAnimating()
                self.animateOut(desiredView: self.popUpView)
                self.animateOut(desiredView: self.blurView)
                
                // show error message
                NotificationBanner.show("Meetups could not be scheduled because of incomplete preferences. Go to the Settings page to complete them.")
            }
        }
        
    }
    
    func getDaysInNextMonth(nextMonth: Int, year: Int) -> Int{
        let dateComponents = DateComponents(year: year, month: nextMonth)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func getDate(day: Int, month: Int, year: Int) -> Date{
        let calendar = Calendar.current

        var components = DateComponents()

        components.day = day
        components.month = month
        components.year = year

        return calendar.date(from: components)!
        
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
    
    func getTimeSlot(timeSlotsAvailable: [[Int]], durationOfMeetup: Int) -> [[Int]]{
        var numOfMinutes = (timeSlotsAvailable[1][0] - timeSlotsAvailable[0][0])*60
        numOfMinutes -= timeSlotsAvailable[0][1]
        numOfMinutes += timeSlotsAvailable[1][1]
        numOfMinutes -= durationOfMeetup
        
        // TODO: Start at 5 minutes mark
        let chosenMinute = Int.random(in: 0...numOfMinutes)
        let startMinutes = (timeSlotsAvailable[0][1] + chosenMinute)%60
        let startHour = timeSlotsAvailable[0][0] + (timeSlotsAvailable[0][1] + chosenMinute)/60
        
        let endMinutes = (startMinutes + durationOfMeetup)%60
        let endHour = startHour + (startMinutes + durationOfMeetup)/60
        
        return [[startHour, startMinutes], [endHour, endMinutes]]
    }
    
    func getRandomDates(DatesTimesAvailable: [Date: [[Int]]], numOfMeetupsPerMonth: Int, durationOfMeetup: Int) -> [Date: [[Int]]]{
        var selectedDatesTime: [Date: [[Int]]] = [:]
        let availableDates = Array(DatesTimesAvailable.keys)
        //print("HERE1111", availableDates.count)
        
        var randomIndex = Set<Int>()
        if(numOfMeetupsPerMonth <= availableDates.count){
            while randomIndex.count != numOfMeetupsPerMonth{
                randomIndex.insert(Int.random(in: 0..<availableDates.count))
            }
            for index in randomIndex{
                selectedDatesTime[availableDates[index]] = getTimeSlot(timeSlotsAvailable: DatesTimesAvailable[availableDates[index]]!, durationOfMeetup: durationOfMeetup)
                print(index, selectedDatesTime[availableDates[index]])
            }
        }
        else{
            for index in 0..<availableDates.count{
                selectedDatesTime[availableDates[index]] = getTimeSlot(timeSlotsAvailable: DatesTimesAvailable[availableDates[index]]!, durationOfMeetup: durationOfMeetup)
                print(index, selectedDatesTime[availableDates[index]])
            }
        }
        
        
        return selectedDatesTime
    }
    
    func getFriends(listFriends: Dictionary<String, Array<String>> , numberOfFriends: Int) ->  Array<String>{
        print("numberOfFriends", numberOfFriends)
        var selectedFriends = Array<String>()
        var alreadySelected = Set<String>()
        var currMeetupFriends = Array<String>()
        var prevMeetupFriends =  Array<String>()
        
        // TODO: get meetup friends for previous month
        // let prevMeetupFriends =
        // currMeetupFriends = listFriends  - prevMeetupFriends
        currMeetupFriends = Array(listFriends.keys)
        
        if(currMeetupFriends.count > numberOfFriends){
            while selectedFriends.count != numberOfFriends{
                let randomSelected  = currMeetupFriends.randomElement()!
                if(alreadySelected.contains(randomSelected)){
                    continue
                }
                    
                alreadySelected.insert(randomSelected)
                selectedFriends.append(randomSelected)
            }
        }
        else{
            for friend in currMeetupFriends{
                selectedFriends.append(friend)
                alreadySelected.insert(friend)
            }
            
            if(selectedFriends.count < numberOfFriends){
                // prioratize previous month meetup friends
                if(prevMeetupFriends.count > numberOfFriends-selectedFriends.count){
                    while selectedFriends.count != numberOfFriends{
                        let randomSelected  = prevMeetupFriends.randomElement()!
                        print(randomSelected)
                        if(alreadySelected.contains(randomSelected)){
                            continue
                        }
                            
                        alreadySelected.insert(randomSelected)
                        selectedFriends.append(randomSelected)
                    }
                    
                }
                else{
                    for friend in prevMeetupFriends{
                        selectedFriends.append(friend)
                    }
                    
                    if(selectedFriends.count < numberOfFriends){
                        // choose rest from entire list of friends
                        while selectedFriends.count != numberOfFriends{
                            let randomSelected  = listFriends.randomElement()!
                            print(randomSelected)
                            selectedFriends.append(randomSelected.key)
                        }
                    }
                }
            }
        }
        
        print("Selected Friends")
        for friend in selectedFriends{
            print(friend)
        }
        
        return selectedFriends
    }
    
    func getStatusOfCalendarAccess() ->Bool{
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
            case EKAuthorizationStatus.authorized:
                return true
            default:
                return false
        }
    }
    
    func getHourMinuteOfEvent(date: Date) -> [Int]{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "PST")
        
        //print(dateFormatter.string(from: date))
        let pstDate = dateFormatter.date(from: dateFormatter.string(from: date))
        //print(pstDate)
        
        let hour = Calendar.current.component(.hour, from: pstDate!)
        let minute = Calendar.current.component(.minute, from: pstDate!)
        print(hour, minute)
        return [hour, minute]
    }
    
    func printDatePST(date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "PST")
        
        let pstDate = dateFormatter.date(from: dateFormatter.string(from: date))
        print(pstDate)
    }
    
    func getWeekDay(from date: Date) -> String{
        let df = DateFormatter()

        return df.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
    
    func getHourMinuteFrom(String date: String) -> [Int]{
        var time:[Int] = []
        
        for val in date.split(separator: ":"){
            time.append(Int(val) ?? 0)
        }
        
        return time
    }
    
    func getDate(date curDate:Date, hourMinute time: [Int]) -> Date{
        
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .hour, value: time[0], to: curDate)
        let evenNewDate = calendar.date(byAdding: .minute, value: time[1], to: newDate!)!
        return evenNewDate
    }
    
    func compareTime(firstTime: Array<Int>, secondTime: Array<Int>) -> Int{ // return 1 when firstTime>secondTime return -1 when secondTime>firstTime 10>11 else 0
        if(firstTime[0] > secondTime[0]){
            return 1
        }
        else if(firstTime[0] < secondTime[0]){
            return -1
        }
        else{ //firstTime[0] == secondTime[0]
            if(firstTime[1] > secondTime[1]){
                return 1
            }
            else if(firstTime[1] < secondTime[1]){
                return -1
            }
        }
        
        return 0
    }
    
    func mergeEvents(events: Array<EKEvent>) -> Array<Array<Int>>{
        var mergedEvents = Array<Array<Int>>()
        
        for event in events{
            let startE = getHourMinuteOfEvent(date: event.startDate)
            let endE = getHourMinuteOfEvent(date: event.endDate)
            
            if(mergedEvents.count == 0){
                mergedEvents.append(startE)
                mergedEvents.append(endE)
            }
            else{
                if(compareTime(firstTime: mergedEvents[mergedEvents.count-1], secondTime: startE) >= 0){
                    if(compareTime(firstTime: mergedEvents[mergedEvents.count-1], secondTime: endE) == -1){
                        mergedEvents.popLast()
                        mergedEvents.append(endE)
                    }
                }
                else{
                    mergedEvents.append(startE)
                    mergedEvents.append(endE)
                }
                
            }
        }
        
        return mergedEvents
    }
    
    func scheduleEvents(){
        // TODO: consider whole day events and remove them
        
        let valuesNextMonth = getNextMonth(today: Date())
        let nextMonth: Int = valuesNextMonth.0
        let year: Int = valuesNextMonth.1
        let daysInNextMonth:Int = getDaysInNextMonth(nextMonth: nextMonth, year: year)
        
        // TODO: If events for next month is scheduled then return
        print(nextMonth, year)
        
        var DatesTimesAvailable : [Date: [[Int]]] = [:]
        let calendarAccess:Bool = getStatusOfCalendarAccess()
        
        
        if(prefDayTime.count != 0){  // User has provided preference for day and time
            // Populate the dates for next month and available time slots
           
            for day in 1...daysInNextMonth{
                // Form date and insert
                let curDate:Date = getDateTime(day: day, month: nextMonth, year: year, hour: 0, minute: 0)
                //let curDate:Date = getDate(day: day, month: nextMonth, year: year)
                let weekDay:String = getWeekDay(from: curDate)
                //print("weekDay", weekDay)
                if(prefDayTime[weekDay] != nil){
                    for (startTime,endTime) in prefDayTime[weekDay]!{
                        let stInt = getHourMinuteFrom(String : startTime)
                        let etInt = getHourMinuteFrom(String : endTime)
                        let timeInSlot = (etInt[0]-stInt[0])*60 - stInt[1] + etInt[1]
                        
                        if(timeInSlot < durationOfMeetup){
                            continue
                        }
                        
                        if( DatesTimesAvailable[curDate] == nil){
                            DatesTimesAvailable[curDate] = [stInt, etInt]
                        }
                        else{
                            DatesTimesAvailable[curDate]?.append(stInt)
                            DatesTimesAvailable[curDate]?.append(etInt)
                        }
                    }
                }
                /*else{
                    DatesTimesAvailable[curDate] = [[9,0], [21,0]] // Date -> (availStartTime, availEndTime)
                }*/
                
            } // For closed
            
            
            if(calendarAccess){ // If iCal access is available
                //print("In ICAL")
                let eventstore:EKEventStore = EKEventStore()
                var slotFound = false
                var finalAvailSlot = Array<Array<Int>>()
                //var prevDate:Date = Date()
                
                for date in DatesTimesAvailable.keys{
                    //print ("For" , date)
                    finalAvailSlot.removeAll()
                    slotFound = false
                    //prevDate = date
                    //var indexToEliminate = Set<Int>()
                    var countEliminations = 0
                    
                    for index in stride(from: 0, to: Int(DatesTimesAvailable[date]!.count), by: 2){
                        //print(index)
                       // print("For big slot", index, printDatePST(date: date), DatesTimesAvailable[date]![index], DatesTimesAvailable[date]![index+1])
                        
                        let startDate:Date = getDate(date: date, hourMinute: DatesTimesAvailable[date]![index])
                        printDatePST(date: startDate)
                        
                        let endDate:Date = getDate(date: date, hourMinute: DatesTimesAvailable[date]![index+1])
                        printDatePST(date: endDate)

                        // Fetch events for that day
                        let predicate = eventstore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                        let events = eventstore.events(matching: predicate)
                        
                        if(events.count == 0){
                            //print("Day has no events enjoy")
                            if(index != 0){
                                DatesTimesAvailable[date]![0] = DatesTimesAvailable[date]![index]
                                DatesTimesAvailable[date]![1] = DatesTimesAvailable[date]![index+1]
                            }
                            slotFound = true
                            break
                        }
                        else{
                            //print("Day has events")
                            // TODO: Change to [[Int]] type
                            var insideEvents = Array<EKEvent>()
                            var outsideEvents = Array<EKEvent>()
                            // find events which start and end inside the slot
                            var slotNotAvailable = false // Set to true when an events spans more than the current slot
                            for event in events{
                                let startE = getHourMinuteOfEvent(date: event.startDate)
                                let endE = getHourMinuteOfEvent(date: event.endDate)
                                
                                if(startE[0] < DatesTimesAvailable[date]![index][0] ){
                                    if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                        slotNotAvailable = true
                                        break
                                    }
                                    else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] >= DatesTimesAvailable[date]![index+1][1]){
                                        slotNotAvailable = true
                                        break
                                    }
                                    outsideEvents.append(event)
                                }
                                else if(startE[0] > DatesTimesAvailable[date]![index][0] ){
                                    if(endE[0] < DatesTimesAvailable[date]![index+1][0]){
                                        insideEvents.append(event)
                                    }
                                    else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] <= DatesTimesAvailable[date]![index+1][1]){
                                        insideEvents.append(event)
                                    }
                                    else{
                                        if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                            slotNotAvailable = true
                                            break
                                        }
                                        else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] >= DatesTimesAvailable[date]![index+1][1]){
                                            slotNotAvailable = true
                                            break
                                        }

                                        outsideEvents.append(event)
                                    }
                                }
                                else{ //startE[0] == DatesTimesAvailable[date]![index][0]
                                    if(startE[1] < DatesTimesAvailable[date]![index][1]){
                                        if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                            slotNotAvailable = true
                                            break
                                        }
                                        else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] >= DatesTimesAvailable[date]![index+1][1]){
                                            slotNotAvailable = true
                                            break
                                        }
                                        outsideEvents.append(event)
                                    }
                                    else if(startE[1] >= DatesTimesAvailable[date]![index][1]){
                                        if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                            if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                                slotNotAvailable = true
                                                break
                                            }
                                            else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] >= DatesTimesAvailable[date]![index+1][1]){
                                                slotNotAvailable = true
                                                break
                                            }
                                            outsideEvents.append(event)
                                        }
                                        else{
                                            if(endE[1] > DatesTimesAvailable[date]![index+1][1]){
                                                if(endE[0] > DatesTimesAvailable[date]![index+1][0]){
                                                    slotNotAvailable = true
                                                    break
                                                }
                                                else if(endE[0] == DatesTimesAvailable[date]![index+1][0] && endE[1] >= DatesTimesAvailable[date]![index+1][1]){
                                                    slotNotAvailable = true
                                                    break
                                                }

                                                outsideEvents.append(event)
                                            }
                                            else{
                                                insideEvents.append(event)
                                            }
                                        }
                                    }
                                }
                            } // Processing for inside and outside events separation completed
                            
                            /*print("Events seperated")
                            print("Inside Events##")
                            for event in insideEvents{
                                print(event.title)
                            }
                            print("##")
                            print("Outside Events##")
                            for event in outsideEvents{
                                print(event.title)
                            }
                            print("##")
                            print("slotNotAvailable, eliminate this slot", slotNotAvailable)*/
                            if(!slotNotAvailable) {
                                var updatedDateTimeAvail = Array<Array<Int>>()
                                if(insideEvents.count != 0){
                                    //print("Merging insideEvents")
                                    // merge these events
                                    let mergedEvents = mergeEvents(events: insideEvents)
                                    
                                    
                                    /*print("Merged Events##")
                                    print(mergedEvents)
                                    print("##")*/
                                    
                                    // break the slot
                                    if(compareTime(firstTime: mergedEvents[0], secondTime: DatesTimesAvailable[date]![index]) == -1){
                                        updatedDateTimeAvail.append(DatesTimesAvailable[date]![index])
                                        updatedDateTimeAvail.append(mergedEvents[0])
                                    }
                                    
                                    for index in stride(from: 2, to: Int(mergedEvents.count), by: 2){
                                        updatedDateTimeAvail.append(mergedEvents[index-1])
                                        updatedDateTimeAvail.append(mergedEvents[index])
                                    }
                                    
                                    if(compareTime(firstTime: mergedEvents[mergedEvents.count-1], secondTime: DatesTimesAvailable[date]![index+1]) == -1){
                                        updatedDateTimeAvail.append(mergedEvents[mergedEvents.count-1])
                                        updatedDateTimeAvail.append(DatesTimesAvailable[date]![index+1])
                                    }
                                    //print("Small slot ", index, updatedDateTimeAvail[0], "-", updatedDateTimeAvail[1])
                                }
                                else{
                                    updatedDateTimeAvail.append(DatesTimesAvailable[date]![index])
                                    updatedDateTimeAvail.append(DatesTimesAvailable[date]![index+1])
                                }
                                
                        
                                // Trim slot according to outsideEvents
                                for index in stride(from: 0, to: Int(updatedDateTimeAvail.count), by: 2){
                                    
                                    //print("Small slot ", index, updatedDateTimeAvail[index], "-", updatedDateTimeAvail[index+1])
                                    for event in outsideEvents{
                                       // print("Considering events inside small slot", event.title)
                                        let startE = getHourMinuteOfEvent(date: event.startDate)
                                        let endE = getHourMinuteOfEvent(date: event.endDate)
                                        
                                        if(compareTime(firstTime: updatedDateTimeAvail[index], secondTime: startE) == 1){
                                            if(compareTime(firstTime: updatedDateTimeAvail[index+1], secondTime: endE) == 1){
                                                // slot trim at front
                                                //print("Checking for 4th Dec", updatedDateTimeAvail[index], endE)
                                                updatedDateTimeAvail[index] = endE
                                                //print("Checking for 4th Dec", updatedDateTimeAvail[index], endE)
                                            }
                                            else{
                                                // slot not viable
                                                //print("Wrong 1: Checking for 4th Dec")
                                                updatedDateTimeAvail[index] =  updatedDateTimeAvail[index+1]
                                                break
                                            }
                                            
                                        }
                                        else if(compareTime(firstTime: updatedDateTimeAvail[index], secondTime: startE) == -1){
                                            // slot trim at end
                                            //print("Wrong 2: Checking for 4th Dec")
                                            updatedDateTimeAvail[index+1] = startE
                                        }
                                        else{
                                            //print("Wrong 3: Checking for 4th Dec")
                                            // slot not viable
                                            updatedDateTimeAvail[index] =  updatedDateTimeAvail[index+1]
                                            break
                                        }
                                    }
                                    
                                    // check duration of this slot
                                    let durationOfSlot  = (updatedDateTimeAvail[index+1][0] - updatedDateTimeAvail[index][0])*60 - updatedDateTimeAvail[index][1] + updatedDateTimeAvail[index+1][1]
                                    
                                    //print("DurationOfSlot ", durationOfSlot)
                                    if(durationOfSlot >= durationOfMeetup){
                                        finalAvailSlot = [updatedDateTimeAvail[index], updatedDateTimeAvail[index+1]]
                                        slotFound = true
                                        
                                    }
                                    
                                    if(slotFound){
                                        //print("small slot found1")
                                        break
                                    }
                                }
                            }
                            else{
                                //print("eliminating this slot")
                                //indexToEliminate.insert(index)
                                countEliminations += 1
                            }
                        }
                        
                        if(slotFound){
                            //print("small slot found2")
                            //print("Final slot found for \(date) \(finalAvailSlot)")
                            DatesTimesAvailable[date] = finalAvailSlot
                            break
                        }
                    }
                    //print("slotFound", slotFound)
                    if(!slotFound){
                        //print("No final slot found for \(date)")
                        DatesTimesAvailable[date] = nil
                    }
                    
                }
                
                // if was here, prevDate why?
            }
            else{ // If iCal access is not available
                // Do nothing
            }
           
            for date in DatesTimesAvailable{
                print("Final slots", date.key, date.value)
            }
            
        }
        else{ // User provided no preference for day and time
            
            if(calendarAccess){ // If iCal access is available
                
                let eventstore:EKEventStore = EKEventStore()
                // Populate the dates for next month and available time slots
                for day in 1...daysInNextMonth{
                    // Form date and insert
                    let startDate:Date = getDateTime(day: day, month: nextMonth, year: year, hour: 00, minute: 00)
                    let endDate:Date = getDateTime(day: day, month: nextMonth, year: year, hour: 23, minute: 59)
                    
                    // Fetch events for that day
                    let predicate = eventstore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                    let events = eventstore.events(matching: predicate)
                    
                    if(events.count == 0){
                        DatesTimesAvailable[startDate] = [[9,0], [21,0]] // Date -> (availStartTime, availEndTime)
                        print("AvailDate", startDate,  DatesTimesAvailable[startDate])
                        continue
                    }
                    
                    // Compare with default startTime the start of first event
                    // Extract first event hour and minute
                    // TODO: Check for events spanning multiple days
                    let eventTiming = getHourMinuteOfEvent(date: events[0].startDate)
                    var availTime = 0
                    if(eventTiming[0] > 9){
                        availTime = (eventTiming[0] - 9)*60 + eventTiming[1]
                    }
                    else if(eventTiming[0] == 9){
                        availTime = eventTiming[1]
                    }
                    
                    if(availTime >= durationOfMeetup){
                        DatesTimesAvailable[startDate] = [[9,0], [eventTiming[0], eventTiming[1]]] // Date -> (availStartTime, availEndTime)
                        print("AvailDate", startDate,  DatesTimesAvailable[startDate])
                    }
                    else{
                        for index in 1..<events.count{
                            // compare endTime of prevEvent and startTime of currentEvent
                            let prevMeetingEndTime = getHourMinuteOfEvent(date: events[index-1].endDate)
                            let curMeetingStartTime = getHourMinuteOfEvent(date: events[index].startDate)
                            
                            availTime = 0
                            availTime = (curMeetingStartTime[0]-prevMeetingEndTime[0])*60
                            availTime -= prevMeetingEndTime[1]
                            availTime += curMeetingStartTime[1]
                            
                            if(availTime >= durationOfMeetup){
                                DatesTimesAvailable[startDate] = [prevMeetingEndTime, curMeetingStartTime]
                                print("AvailDate", startDate,  DatesTimesAvailable[startDate])
                                break
                            }
                            
                            //print("Event: \(String(describing: event.title))")
                        }
                    }
                    
                    if((DatesTimesAvailable.index(forKey: startDate)) == nil){
                        let eventTiming = getHourMinuteOfEvent(date: events[events.count-1].endDate)
                        if(eventTiming[0] < 21){
                            availTime = (21 - eventTiming[0])*60 - eventTiming[1]
                        }
                        else if(eventTiming[0] == 21){
                            availTime = 60-eventTiming[1]
                        }
                        
                        if(availTime >= durationOfMeetup){
                            DatesTimesAvailable[startDate] = [eventTiming, [21, 0]] // Date -> (availStartTime, availEndTime)
                            print("AvailDate", startDate,  DatesTimesAvailable[startDate])
                        }
                    }
                }
                //print("AvailableArray", DatesTimesAvailable)
                
            }
            else{ // If iCal access is not available
                
                // Calculate Default End time for all days
                //let MeetupDefaultEndTime = MeetupDefaultStartTime + durationOfMeetup
                
                // Populate the dates for next month and available time slots
               
                for day in 1...daysInNextMonth{
                    // Form date and insert
                    let curDate:Date = getDate(day: day, month: nextMonth, year: year)
                    DatesTimesAvailable[curDate] = [[9,0], [21,0]] // Date -> (availStartTime, availEndTime)
                }
     
           }
            // Get the Dates for meeting selected randomly over given Dates
            /*let MeetupDatesTime = getRandomDates(DatesTimesAvailable: DatesTimesAvailable, numOfMeetupsPerMonth: numOfMeetupsPerMonth, durationOfMeetup: durationOfMeetup)
            let MeetupFriends = getFriends(listFriends: listFriends, numberOfFriends: MeetupDatesTime.count)*/
            
        }
        
        // Get the Dates for meeting selected randomly over given Dates
        MeetupDatesTime = getRandomDates(DatesTimesAvailable: DatesTimesAvailable, numOfMeetupsPerMonth: numOfMeetupsPerMonth, durationOfMeetup: durationOfMeetup) // Date -> [[startH, startMin], [endH, endMin]]
        MeetupFriends = getFriends(listFriends: listFriends, numberOfFriends: MeetupDatesTime.count)
        // [phoneNumbers, ,...]
        
        // Create Meetup objects
        var count = 0
       
        print("\n\nScheduled Meetups: \(MeetupDatesTime.count), \(MeetupFriends.count)")
        for mdt in MeetupDatesTime{
            let secondsSinceBegin:Int = Int(mdt.key.timeIntervalSince1970)
            var UpcomingMeetups = Dictionary<String, String>()
           
            UpcomingMeetups["TimeStamp"] = String(secondsSinceBegin)
            UpcomingMeetups["Day"] = self.getWeekDay(from: mdt.key)
            UpcomingMeetups["Date"] = self.getDateStringPST(date:  mdt.key)
            UpcomingMeetups["StartTime"] = self.get12HourTimeString(time: MeetupDatesTime[mdt.key]![0])
            UpcomingMeetups["EndTime"] = self.get12HourTimeString(time: MeetupDatesTime[mdt.key]![1])
            UpcomingMeetups["FriendPhoneNumber"] = self.MeetupFriends[count]
            UpcomingMeetups["MeetupHappened"] = String(false)
            count += 1
            print(count-1,". ",UpcomingMeetups["Day"]!,":" ,UpcomingMeetups["Date"]! ,"," , UpcomingMeetups["StartTime"]!, "-", UpcomingMeetups["EndTime"]!, UpcomingMeetups["FriendPhoneNumber"]!)
            
            // create calendar event
            if(self.createCalendarEvents){
                print("1. user wants events")
                let eventStore = EKEventStore()
                let cf:CalendarFunctions = CalendarFunctions()
                if (cf.checkCalendarAccess()){ // access is given for calendar
                    print("2. user had granted calendar access")
                    let calendarEventID = cf.createCalendarEvent(store: eventStore, date: mdt.key, HourMin: MeetupDatesTime[mdt.key]![0], durationOfMeetup: self.durationOfMeetup, friendName: listFriends[UpcomingMeetups["FriendPhoneNumber"]!]![0])
                    UpcomingMeetups["CalendarEventID"] = calendarEventID!
                    print("3. Event created", calendarEventID!)
                    // Insert meetup
                    print("4. Meetup added to firebase")
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document().setData(UpcomingMeetups, merge: true)
                }
                else{ // access is not given for calendar
                    print("2. user hadn't granted calendar access")
                    /*if(cf.getCalendarAccess(eventStore: eventStore)){ // ask for permission and access granted by user
                        print("3. user now granted calendar access")
                        let calendarEventID = cf.createCalendarEvent(store: eventStore, date: mdt.key, HourMin: MeetupDatesTime[mdt.key]![0], durationOfMeetup: self.durationOfMeetup, friendName: listFriends[UpcomingMeetups["FriendPhoneNumber"]!]![0])
                        UpcomingMeetups["CalendarEventID"] = calendarEventID!
                        // Insert meetup
                        print("4. Event created", calendarEventID!)
                        
                        print("5. Meetup added to firebase")
                        self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document().setData(UpcomingMeetups, merge: true)
                    }
                    else{
                        print("3. user now didn't grant calendar access")
                        // Permission not granted by user so setting preference of adding calendar events to false
                        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": false], merge: true)
                        // Insert meetup
                        print("4. Meetup added to firebase")
                        self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document().setData(UpcomingMeetups, merge: true)
                    }*/
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Calendar Updation Access": false], merge: true)
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document().setData(UpcomingMeetups, merge: true)
                }
            }
            else{
                print("1. Meetup added to firebase as user doesn't want it on calendar")
                self.db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").document().setData(UpcomingMeetups, merge: true)
            }
            
            print("\n")
        }
        
        print("\n\n")
    }
    
    func getDateStringPST(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "PST")
        return (dateFormatter.string(from: date))
    }
    
    func get12HourTimeString(time: Array<Int>) -> String{
        var PM:Bool = false
        var hour = time[0]
        
        if(hour > 12){
            hour -= 12
            PM = true
        }
        if(hour == 12){
            PM = true
        }
        if(hour  == 0){
            hour = 12
        }
        
        var timeString = ""
        if(hour < 10){
            timeString += "0"
        }
        
        timeString += String(hour) + ":"
        
        if(time[1] < 10){
            timeString += "0"
        }
        timeString += String(time[1])
        
        if(PM){
            timeString += " PM"
        }
        else{
            timeString += " AM"
        }
        
        return timeString
    }
    
    func getNextMonth(today: Date) -> (Int, Int){
        let nextMonthDay = Calendar.current.date(byAdding: .month, value: 1, to: today)
        let nextMonth = Calendar.current.component(.month, from: nextMonthDay!)
        let year = Calendar.current.component(.year, from: nextMonthDay!)
        // print(nextMonthDay, nextMonth)
        return (nextMonth, year)
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
    
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error Signing out- %@", signOutError)
        }
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginViewController
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func SettingButtonTapped(_ sender: Any) {
    }
    @IBAction func AnalyticsButtonDashboard(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnalyticsVC") as? AnalyticsDashboardViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func CalendarButtonTapped(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EventsVC") as? EventsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func RewardsButtonTapped(_ sender: Any) {
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

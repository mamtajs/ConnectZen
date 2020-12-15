//
//  TimeDayPrefViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/8/20.
//

import UIKit
import Firebase
import FirebaseUI

class TimeDayPrefViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PassBackPreference {
    @IBOutlet weak var FrequencyLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var FrequencyStepperElem: UIStepper!
    @IBOutlet weak var TimeStepperElem: UIStepper!
    @IBOutlet weak var PrefTableView: UITableView!
    
    @IBOutlet weak var preferencesAddedButton: UIButton!
    
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    var SavedPreference: [PrefDayTime] = [] // saved preferences of user
    var durationVal = 15
    var frequencyVal = 1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(SavedPreference.count)")
        return SavedPreference.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return UITableViewCell()
        print("Adding new cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrefDayTimeTableViewCell") as! PrefDayTimeTableViewCell
        cell.ActionButton.tintColor = UIColor(red: 0.836095, green: 0.268795, blue: 0.178868, alpha: 1)
        cell.cellDelegate = self
       
        //let cell = UITableViewCell()
        print(indexPath)
        //cell.textLabel?.text = "\(connectWith[indexPath.row].contactName) \t \(connectWith[indexPath.row].PhoneNumber)"
        cell.DayLabel.text = "\(SavedPreference[indexPath.row].Day)"
        cell.StartTimeLabel.text = "\(SavedPreference[indexPath.row].StartTime)"
        cell.EndTimeLabel.text = "\(SavedPreference[indexPath.row].EndTime)"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        Utilities.styleFilledButton(preferencesAddedButton, cornerRadius: xLargeCornerRadius)
        //print("Initial \(TimeStepperElem.value)")
        self.PrefTableView.delegate = self
        self.PrefTableView.dataSource = self
        
        
        setDataFromFirebase()
    }
    //To hide navigation bar in a particular view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        if dayTimePrefPageFlag == 1{
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
            self.tabBarController?.navigationController?.navigationBar.topItem?.title  = "Time and Day preferences"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dayTimePrefPageFlag = 0
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func setDataFromFirebase(){
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc, doc.exists{
                if doc.get("Preferred Duration") != nil{
                    //dayTimePrefPageFlag = 1
                    let prefDuration = doc["Preferred Duration"] as! Double
                    let prefFrequency = doc["Preferred Frequency"] as! Double
                    self.TimeStepperElem.value = prefDuration
                    self.FrequencyStepperElem.value = prefFrequency
                    self.TimeLabel.text = "I would like to connect for \(Int(self.TimeStepperElem.value)) minutes per meeting"
                    self.FrequencyLabel.text = "I would like to connect with \(Int(self.FrequencyStepperElem.value)) friend(s) per month"
                    
                    
                    let dayTimePref = doc["Day and Time Preferences"] as! [String:[String:String]]
                    let keysArray = Array(dayTimePref.keys)
                   
                    if keysArray.count != 0{
                        for dayIndex in 0...keysArray.count-1{
                            let day = keysArray[dayIndex]
                            let startTimeArray = Array(dayTimePref[day]!.keys)
                            for timeIndex in 0...startTimeArray.count-1{
                                let startTime = startTimeArray[timeIndex]
                                let endTime = dayTimePref[day]![startTime]
                                let startTimeFinal = self.convertTo12HourFormat(time: startTime)
                                let endTimeFinal = self.convertTo12HourFormat(time: endTime!)
                                print(day, startTimeFinal, endTimeFinal)
                                self.SavedPreference.append(PrefDayTime(Day: day, StartTime: startTimeFinal, EndTime: endTimeFinal))
                            }
                        }
                        self.PrefTableView.reloadData()
                    }
                }else{
                    print("Document does not exist")
                    self.TimeStepperElem.value = Double(self.durationVal)
                    self.FrequencyStepperElem.value = Double(self.frequencyVal)
                }
                
                
            }
            else{
                print("Error reading the user document")
                self.TimeStepperElem.value = Double(self.durationVal)
                self.FrequencyStepperElem.value = Double(self.frequencyVal)
            }
        }
    }
    
    func convertTo12HourFormat(time: String) -> String{
        var formedTime: String
        let splitOne = time.split(separator: ":")
        var hour = Int(splitOne[0])
        let minute = Int(splitOne[1])
        if hour! > 12{
            hour! -= 12
            formedTime = String(format: "%02d", hour!) + ":" + String(format: "%02d", minute!) + " PM"
        }else if hour! == 0{
            hour! += 12
            formedTime = String(format: "%02d", hour!) + ":" + String(format: "%02d", minute!) + " AM"
        }else{
            formedTime = String(format: "%02d", hour!) + ":" + String(format: "%02d", minute!) + " AM"
        }
        return formedTime
    }
    
    
    @IBAction func FrequencyStepper(_ sender: UIStepper) {
        print("Frequency stepper- \(Int(sender.value))")
        // Handle Frequency label with Frequency Stepper
        FrequencyLabel.text = "I would like to connect with \(Int(sender.value)) friend(s) per month"
        frequencyVal = Int(sender.value)
    }
    
    @IBAction func TimeStepper(_ sender: UIStepper) {
        print("Time stepper- \(Int(sender.value))")
        // Handle Time label with Time Stepper
        TimeLabel.text = "I would like to connect for \(Int(sender.value)) minutes per meeting"
        durationVal = Int(sender.value)
    }
    
    
    @IBAction func AddDayTimeClicked(_ sender: Any) {
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
    
    func OnPrefAddition(Day: String,  StartDate: Date, EndDate: Date) {
        print("Got back \(Day) \(StartDate) \(EndDate)")
        
        var sHrMin:Time = Time(Hour: 0,Minute: 0)
        sHrMin.Hour = Calendar.current.component(.hour, from: StartDate)
        sHrMin.Minute = Calendar.current.component(.minute, from: StartDate)
        
        var eHrMin:Time = Time(Hour: 0,Minute: 0)
        eHrMin.Hour = Calendar.current.component(.hour, from: EndDate)
        eHrMin.Minute = Calendar.current.component(.minute, from: EndDate)
        
        // check if startTime is less than endTime
        if(compareTime(hour1: sHrMin.Hour, minute1: sHrMin.Minute, hour2: eHrMin.Hour, minute2: eHrMin.Minute) >= 0){
            NotificationBanner.showFailure("Start time of event can not be greater than or equal to the end time, please correct and try again!")
        }
        else{
            self.SavedPreference.append(PrefDayTime(Day: Day, StartTime: StartDate.dateStringWith(strFormat: "hh:mm a"), EndTime: EndDate.dateStringWith(strFormat: "hh:mm a")))
        
            PrefTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is UserPrefDayTimePopUpViewController
        {
            let vc = segue.destination as? UserPrefDayTimePopUpViewController
            vc?.delegate = self
            //vc?.username = "Arthur Dent"
        }
    }
    
    func convertTo24HourFormat(time: String) -> String{
        var formedTime: String
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
        formedTime = String(hour!) + ":" + String(minute!)
        return formedTime
    }
    
    func getHourMinuteFrom(String date: String) -> [Int]{
        var time:[Int] = []
        
        for val in date.split(separator: ":"){
            time.append(Int(val) ?? 0)
        }
        
        return time
    }
    
    func compareTime2(firstTime: Array<Int>, secondTime: Array<Int>) -> Int{ // return 1 when firstTime>secondTime return -1 when secondTime>firstTime 10>11 else 0
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
    
    func getMinutes(time: String) -> Int{
        let hrMin = getHourMinuteFrom(String: time)
        return hrMin[0]*60 + hrMin[1]
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        // Adding duration and frequency preferences
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Preferred Duration": durationVal], merge: true)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Preferred Frequency": frequencyVal], merge: true)
        // Adding day and time preferences
        print(SavedPreference)
        var preferences = Dictionary<String, Dictionary<String, String>>()
        for prefDay in SavedPreference{
            var timesOnDay = Dictionary<String, String>()
            var minutesToSort =  Dictionary<Int, Array<String>>()
            for prefTimes in SavedPreference{
                if(prefTimes.Day == prefDay.Day){
                    
                // TO DO: Convert to 24 hour format
                    let startTimeUpdated: String = convertTo24HourFormat(time: prefTimes.StartTime)
                    let endTimeUpdated: String = convertTo24HourFormat(time: prefTimes.EndTime)
                    //print("startTime: ", startTimeUpdated)
                    //print("endTime: ", endTimeUpdated)
                    let timeStamp = getMinutes(time: startTimeUpdated)
                    
                    //print("H: \(hour) M: \(minute) TP: \(timePeriod)")
                    timesOnDay[startTimeUpdated] = endTimeUpdated
                    minutesToSort[timeStamp] = [startTimeUpdated, endTimeUpdated]
                }
            }
            // sort dictionary timesOnDay
            let sorted = minutesToSort.sorted { $0.key < $1.key }
            var startTimesSorted = Array<String>()
            var endTimesSorted = Array<String>()
            let times = Array(sorted.map({ $0.value }))
            for time in times{
                startTimesSorted.append(time[0])
                endTimesSorted.append(time[1])
            }
            
            //print("Sorted Arrays")
            //print(startTimesSorted)
            //print(endTimesSorted)
            // processing
            var curIndex = 0
            var curTimeS = Array<Int>()
            var curTimeE = Array<Int>()
            
            var nextTimeS = Array<Int>()
            var nextTimeE = Array<Int>()
            
            timesOnDay.removeAll()
            
            curTimeS = getHourMinuteFrom(String: startTimesSorted[curIndex])
            curTimeE = getHourMinuteFrom(String: endTimesSorted[curIndex])
            
            //var key = String(curTimeS[0]) + ":" + String(curTimeS[1])
            //var val = String(curTim[0]) + ":" + String(curTimeS[1])
            timesOnDay[startTimesSorted[0]] = endTimesSorted[0]
            var overlapStatus:Bool = false
            for index in 1..<startTimesSorted.count{
                nextTimeS = getHourMinuteFrom(String: startTimesSorted[index])
                nextTimeE = getHourMinuteFrom(String: endTimesSorted[index])
                
                if(compareTime2(firstTime: curTimeS, secondTime: nextTimeS) <= 0 && compareTime2(firstTime: curTimeE, secondTime: nextTimeS) >= 0){
                    // overlapping
                    if(compareTime2(firstTime: curTimeE, secondTime: nextTimeE) < 0){
                        //print("Overlapped", curIndex ,curTimeS, curTimeE, nextTimeS, nextTimeE)
                        curTimeE = nextTimeE
                        timesOnDay[startTimesSorted[curIndex]] = String(curTimeE[0]) + ":" + String(curTimeE[1])
                        overlapStatus = true
                    }
                    
                }
                else{
                    if(overlapStatus){
                        //print("Not Overlapped", curIndex ,curTimeS, curTimeE, nextTimeS, nextTimeE)
                        overlapStatus = false
                        timesOnDay[startTimesSorted[curIndex]] = String(curTimeE[0]) + ":" + String(curTimeE[1])
                        curIndex = index
                        curTimeS = nextTimeS
                        curTimeE = nextTimeE
                        timesOnDay[startTimesSorted[curIndex]] = String(nextTimeE[0]) + ":" + String(nextTimeE[1])
                    }
                    else{
                        //print("Not Overlapped 2", curIndex ,curTimeS, curTimeE, nextTimeS, nextTimeE)
                        timesOnDay[startTimesSorted[index]] = endTimesSorted[index]
                        curIndex = index
                        curTimeS = nextTimeS
                        curTimeE = nextTimeE
                    }
                }
                
            }
            
            print(prefDay.Day, "-> ",timesOnDay)
            //exit(20)
            preferences[prefDay.Day] = timesOnDay
        }
        //exit(20)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Day and Time Preferences": preferences], merge: true)
        
        if dayTimePrefPageFlag == 1{
            dayTimePrefPageFlag = 0
            /*let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            self.navigationController?.pushViewController(vc!, animated: true)*/
            navigateToTabBar()
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CalendarVC") as? CalendarViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

extension TimeDayPrefViewController: PrefDayTimeTableViewCellDelegate {
    func PrefDayTimeTableViewCell(cell: PrefDayTimeTableViewCell, didTappedThe button: UIButton?) {
        print("At Gaurd")
        guard let indexPath = PrefTableView.indexPath(for: cell) else  { return }
        print("Cell action in row: \(indexPath.row) \(String(describing: cell.ActionButton.tintColor))")
        
        // Button color is green
        if(cell.ActionButton.tintColor == UIColor(red: 0, green: 0.405262, blue: 0.277711, alpha: 1)){
            // Can not happen so error
            print("Error: Color can not be found")
        }
        else{ // Button color is red
            
            // Show tool tip of removed from connection
            //showToast(controller: self, message: "Preference removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            //Remove person from list of contacts
            SavedPreference.remove(at: indexPath.row)
            
            print(SavedPreference)
            PrefTableView.reloadData()
        }
        
    }
}


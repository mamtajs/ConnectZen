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
   
    var authUI: FUIAuth?
    let db = Firestore.firestore()
    
    var SavedPreference: [PrefDayTime] = [] // saved preferences of user
    var durationVal = 15
    var frequencyVal = 4
    
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
        self.PrefTableView.delegate = self
        self.PrefTableView.dataSource = self
        setDataFromFirebase()
    }
    
    func setDataFromFirebase(){
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument{ (doc, err) in
            if let doc = doc, doc.exists{
                if doc.get("Preferred Duration") != nil{
                    dayTimePrefPageFlag = 1
                    let prefDuration = doc["Preferred Duration"] as! Double
                    let prefFrequency = doc["Preferred Frequency"] as! Double
                    self.TimeStepperElem.value = prefDuration
                    self.FrequencyStepperElem.value = prefFrequency
                    self.TimeLabel.text = "I would like to connect for \(Int(self.TimeStepperElem.value)) minutes per meeting"
                    self.FrequencyLabel.text = "I would like to connect with \(Int(self.FrequencyStepperElem.value)) friend(s) per month"
                    
                    
                    let dayTimePref = doc["Day and Time Preferences"] as! [String:[String:String]]
                    let keysArray = Array(dayTimePref.keys)
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
                }else{
                    print("Document does not exist")
                    self.TimeStepperElem.value = 15
                    self.FrequencyStepperElem.value = 1
                }
                
                
            }
            else{
                print("Error reading the user document")
                self.TimeStepperElem.value = 15
                self.FrequencyStepperElem.value = 1
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
    
    func OnPrefAddition(Day: String, StartTime: String, EndTime: String) {
        print("Got back \(Day) \(StartTime) \(EndTime)")
        
        self.SavedPreference.append(PrefDayTime(Day: Day, StartTime: StartTime, EndTime: EndTime))
        
        PrefTableView.reloadData()
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
    
    @IBAction func nextTapped(_ sender: Any) {
        // Adding duration and frequency preferences
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Preferred Duration": durationVal], merge: true)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Preferred Frequency": frequencyVal], merge: true)
        // Adding day and time preferences
        print(SavedPreference)
        var preferences = Dictionary<String, Dictionary<String, String>>()
        for prefDay in SavedPreference{
            var timesOnDay = Dictionary<String, String>()
            for prefTimes in SavedPreference{
                if(prefTimes.Day == prefDay.Day){
                    
                // TO DO: Convert to 24 hour format
                    let startTimeUpdated: String = convertTo24HourFormat(time: prefTimes.StartTime)
                    let endTimeUpdated: String = convertTo24HourFormat(time: prefTimes.EndTime)
                    print("startTime: ", startTimeUpdated)
                    print("endTime: ", endTimeUpdated)
                    //print("H: \(hour) M: \(minute) TP: \(timePeriod)")
                    timesOnDay[startTimeUpdated] = endTimeUpdated
                }
            }
            preferences[prefDay.Day] = timesOnDay
        }
        //exit(20)
        self.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["Day and Time Preferences": preferences], merge: true)
        
        if dayTimePrefPageFlag == 1{
            dayTimePrefPageFlag = 0
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            self.navigationController?.pushViewController(vc!, animated: true)
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
            showToast(controller: self, message: "Preference removed", seconds: 0.5, colorBackground: .systemGreen, title: "Success")
            
            //Remove person from list of contacts
            SavedPreference.remove(at: indexPath.row)
            
            print(SavedPreference)
            PrefTableView.reloadData()
        }
        
    }
}


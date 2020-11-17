//
//  TimeDayPrefViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/8/20.
//

import UIKit

class TimeDayPrefViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PassBackPreference {
    @IBOutlet weak var FrequencyLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var FrequencyStepperElem: UIStepper!
    @IBOutlet weak var TimeStepperElem: UIStepper!
    @IBOutlet weak var PrefTableView: UITableView!
    
    var SavedPreference = Array<PrefDayTime>() // saved preferences of user
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(SavedPreference.count)")
        return SavedPreference.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return UITableViewCell()
        print("Adding new cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrefDayTimeTableViewCell") as! PrefDayTimeTableViewCell
        cell.ActionButton.tintColor =  UIColor(red: 0.836095, green: 0.268795, blue: 0.178868, alpha: 1)
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
        
        TimeStepperElem.value = 15
        FrequencyStepperElem.value = 1
        
        PrefTableView.delegate = self
        PrefTableView.dataSource = self
        //print("Initial \(TimeStepperElem.value)")
    }
    
    @IBAction func FrequencyStepper(_ sender: UIStepper) {
        // Handle Frequency label with Frequency Stepper
        FrequencyLabel.text = "I would like to connect with \(Int(sender.value)) friend(s) per month"
    }
    
    @IBAction func TimeStepper(_ sender: UIStepper) {
        print(Int(sender.value))
        // Handle Time label with Time Stepper
        TimeLabel.text = "I would like to connect for \(Int(sender.value)) minutes per meeting"
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


//
//  UserPrefDayTimePopUpViewController.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/15/20.
//

import UIKit


class UserPrefDayTimePopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var DayPickerView: UIPickerView!
    
    @IBOutlet weak var StartTimeTimePicker: UIDatePicker!
    @IBOutlet weak var EndTimeTimePicker: UIDatePicker!
    
    @IBOutlet weak var ParentView: UIView!
    @IBOutlet weak var PopUpView: UIView!
    
    var DaySelected:String = ""
    var delegate:PassBackPreference?
    @IBOutlet weak var AddButton: UIButton!
    
    //@IBOutlet weak var DayDropDown: DropDown!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.DayPickerView.delegate = self
        self.DayPickerView.dataSource = self
        
        self.DaySelected = Days[0]
        self.StartTimeTimePicker.date = getTime(Time: "09:00 AM")
        self.EndTimeTimePicker.date = getTime(Time: "09:00 PM")
        StartTimeTimePicker.preferredDatePickerStyle = .inline
        EndTimeTimePicker.preferredDatePickerStyle = .inline
        
        Utilities.styleFilledButton(AddButton, cornerRadius: largeCornerRadius)
        setupPopUpView(popUpView: PopUpView)
    
        
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
    @IBAction func ClosePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return Days[row]
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        self.DaySelected = Days[row] as String
        print(self.DaySelected)
    }
    
    @IBAction func AddPreference(_ sender: Any) {
        //let sTime = self.datePicker.date
        
       // let sTime = self.StartTimeTimePicker.date.dateStringWith(strFormat: "hh:mm a")
        //print(strTime)
        //let eTime = self.EndTimeTimePicker.date.dateStringWith(strFormat: "hh:mm a")
        //print(strTime)
        //print("Here we go ", self.DaySelected, sTime, eTime)
        delegate?.OnPrefAddition(Day: self.DaySelected  , StartDate: self.StartTimeTimePicker.date, EndDate: self.EndTimeTimePicker.date)
        dismiss(animated: true, completion: nil)
    }
    
    func getTime(Time: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "hh:mm a"

        return dateFormatter.date(from: Time) ?? Date()
    }
    
}

extension Date {
    func dateStringWith(strFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = strFormat
        return dateFormatter.string(from: self)
    }
}

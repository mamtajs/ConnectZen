//
//  MonthViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/7/20.
//

import UIKit
import Charts
import Firebase

class MonthViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var generateChartButton: UIButton!
    
    var yearSelected: Int = 0
    let db = Firestore.firestore()
    var monthSelected: String = ""
    var keysArraySorted:[String] = []
    var weeksWithValues:[String:Int] = ["Week1":0, "Week2":0, "Week3":0, "Week4":0]
    
    private lazy var lineChartView: LineChartView = {
        let ChartView = LineChartView()
        ChartView.backgroundColor = .systemBackground
        return ChartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yearSelected = Int(Years[0])!
        self.monthSelected = Months[0]
        // Do any additional setup after loading the view.
        Utilities.styleFilledButton(generateChartButton, cornerRadius: xLargeCornerRadius)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
                return Years.count
            } else {
                return Months.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
                return Years[row]
            } else {
                return Months[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if pickerView.tag == 1 {
            self.yearSelected = Int(Years[row])!
        } else {
            self.monthSelected = Months[row]
        }
    }
    
    @IBAction func generateChartTapped(_ sender: Any) {
        self.weeksWithValues.removeAll()
        //self.weeksWithValues = ["Week1":0, "Week2":0, "Week3":0, "Week4":0]
        /*weeksWithValues["Week1"] = 0
        weeksWithValues["Week2"] = 0
        weeksWithValues["Week3"] = 0
        weeksWithValues["Week4"] = 0*/
        
        loadMonthlyDataFirebase(month: monthToInt[self.monthSelected]!, year: self.yearSelected)
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
    
    func loadMonthlyDataFirebase(month: Int, year: Int){
        
        let monthStartDate = getDateTime(day: 1, month: month, year: year, hour: 0, minute: 0)
        let range = Calendar.current.range(of: .day, in: .month, for: monthStartDate)!
        let numDays = range.count
        let monthEndDate = getDateTime(day: numDays, month: month, year: year, hour: 23, minute: 59)
        
        let startTimeStamp = String(monthStartDate.timeIntervalSince1970)
        let endTimeStamp = String(monthEndDate.timeIntervalSince1970)
        
        let week1EndTimestamp = String(getDateTime(day: 7, month: month, year: year, hour: 23, minute: 59).timeIntervalSince1970)
        let week2StartTimestamp = String(getDateTime(day: 8, month: month, year: year, hour: 0, minute: 0).timeIntervalSince1970)
        print(week2StartTimestamp)
        let week2EndTimestamp = String(getDateTime(day: 14, month: month, year: year, hour: 23, minute: 59).timeIntervalSince1970)
        let week3StartTimestamp = String(getDateTime(day: 15, month: month, year: year, hour: 0, minute: 0).timeIntervalSince1970)
        let week3EndTimestamp = String(getDateTime(day: 21, month: month, year: year, hour: 23, minute: 59).timeIntervalSince1970)
        let week4StartTimestamp = String(getDateTime(day: 22, month: month, year: year, hour: 0, minute: 0).timeIntervalSince1970)
        let week4EndTimestamp = String(getDateTime(day: 28, month: month, year: year, hour: 23, minute: 59).timeIntervalSince1970)
        let week5StartTimestamp = String(getDateTime(day: 29, month: month, year: year, hour: 0, minute: 0).timeIntervalSince1970)

        print(weeksWithValues)
        let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isGreaterThanOrEqualTo: startTimeStamp).whereField("TimeStamp", isLessThanOrEqualTo: endTimeStamp)
                query.getDocuments{(querySnapShot, error) in
                    if let error = error{
                        print("Error getting documents: \(error)")
                    }
                    else{
                        for doc in querySnapShot!.documents{
                            let meetupStatus = doc.get("MeetupHappened") as! String
                            let meetUpTimeStamp = doc.get("TimeStamp")
                            if (meetUpTimeStamp as! String) <= week1EndTimestamp{
                                if meetupStatus == "true"{
                                    //weeksWithValues["Week1"] +=
                                    print("meeting in week1")
                                    let week1Val = self.weeksWithValues["Week1"]
                                    self.weeksWithValues.updateValue((week1Val ?? 0) + 1, forKey: "Week1")
                                }
                            }
                            else if(meetUpTimeStamp as! String) <= week2EndTimestamp{
                                if meetupStatus == "true"{
                                    //weeksWithValues["Week1"] +=
                                    print("meeting in week2")
                                    let week2Val = self.weeksWithValues["Week2"]
                                    self.weeksWithValues.updateValue((week2Val ?? 0) + 1, forKey: "Week2")
                                }
                            }
                            else if (meetUpTimeStamp as! String) <= week3EndTimestamp{
                                if meetupStatus == "true"{
                                    //weeksWithValues["Week1"] +=
                                    print("meeting in week3")
                                    let week3Val = self.weeksWithValues["Week3"]
                                    self.weeksWithValues.updateValue((week3Val ?? 0) + 1, forKey: "Week3")
                                }
                            }
                            else if (meetUpTimeStamp as! String) <= week4EndTimestamp{
                                if meetupStatus == "true"{
                                    //weeksWithValues["Week1"] +=
                                    print("meeting in week4")
                                    let week4Val = self.weeksWithValues["Week4"]
                                    self.weeksWithValues.updateValue((week4Val ?? 0) + 1, forKey: "Week4")
                                }
                            }
                            else{
                                if meetupStatus == "true"{
                                    //weeksWithValues["Week1"] +=
                                    print("meeting in week5")
                                    let week5Val = self.weeksWithValues["Week5"]
                                    self.weeksWithValues.updateValue((week5Val ?? 0) + 1, forKey: "Week5")
                                }
                            }
                        }
                        print("Printing with values ", self.weeksWithValues)
                        if (self.weeksWithValues.index(forKey: "Week1") == nil){
                            self.weeksWithValues["Week1"] = 0
                        }
                        if (self.weeksWithValues.index(forKey: "Week2") == nil){
                            self.weeksWithValues["Week2"] = 0
                        }
                        if (self.weeksWithValues.index(forKey: "Week3") == nil){
                            self.weeksWithValues["Week3"] = 0
                        }
                        if (self.weeksWithValues.index(forKey: "Week4") == nil){
                            self.weeksWithValues["Week4"] = 0
                        }
                        self.createChart()
                    }
                }
    }
    
    func createChart(){
        let sorted = weeksWithValues.sorted { $0.key < $1.key }
        keysArraySorted = Array(sorted.map({ $0.key }))
        let valuesArraySorted = Array(sorted.map({ $0.value }))
        
        
        // Creating Chart
        view.addSubview(lineChartView)
        lineChartView.center(in: self.graphView)
        lineChartView.width(to: self.graphView, multiplier: 0.9)
        lineChartView.heightToWidth(of: self.graphView, multiplier: 0.9)
        setChart(dataPoints: keysArraySorted, values: valuesArraySorted)
    }
    
    func setChart(dataPoints: [String], values: [Int]) {
        lineChartView.noDataText = "No data available for this time"
        var dataEntries: [ChartDataEntry] = []
                
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry( x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Number of successful meetups")
        lineChartView.legend.font = UIFont.systemFont(ofSize: 18)
        
        let chartData = LineChartData()
        let marker: BalloonMarker = BalloonMarker(color: brightColor, font: .systemFont(ofSize: 14), textColor: UIColor.black, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 20.0, right: 7.0))
         marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
      
        lineChartView.marker = marker
       
        chartDataSet.colors = [brightColor]
        chartDataSet.fillColor = lightColor
        chartDataSet.drawFilledEnabled = true // Draw the Gradient
        
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.circleColors = [brightColor]
        chartDataSet.circleRadius = 4.0
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(false)
        
        lineChartView.data = chartData
        
        lineChartView.leftAxis.granularityEnabled = true
        lineChartView.leftAxis.granularity = 1.0
        lineChartView.rightAxis.granularityEnabled = true
        lineChartView.rightAxis.granularity = 1.0
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:keysArraySorted)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.animate(yAxisDuration: 0.5, easingOption: .linear)
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 15)
    }
}

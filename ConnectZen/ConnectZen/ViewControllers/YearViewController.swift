//
//  YearViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 12/7/20.
//

import UIKit
import Firebase
import Charts

class YearViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var graphView: UIView!
    var yearSelected: Int = 0
    let db = Firestore.firestore()
    var yForYearly: [Int] = []
    var xForYearly = Dictionary<Int, Int>()
    
    private lazy var lineChartView: LineChartView = {
        let ChartView = LineChartView()
        ChartView.backgroundColor = .systemBackground
        return ChartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        self.yearSelected = Int(Years[0])!
    }
    
    @IBAction func generateChartTapped(_ sender: Any) {
        print(xForYearly)
        print(yForYearly)
        loadYearlyDataFirebase(year: self.yearSelected)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Years.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return Years[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        self.yearSelected = Int(Years[row])!
        print(self.yearSelected)
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
            return calendar.date(from: components)!
        }
    
    
    func loadYearlyDataFirebase(year: Int){
        self.yForYearly.removeAll()
        self.xForYearly.removeAll()
        let numberOfMonths = 12
        for monthNum in 1...numberOfMonths{
            print("Moving into month \(monthNum)")
            //let values = loadMonthOfYearDataFirebase(month: monthNum, year: year)
            //print(values)
            var totalMeetups = 0
            var successfulMeetups = 0
            let monthStartDate = getDateTime(day: 1, month: monthNum, year: year, hour: 0, minute: 0)
            let range = Calendar.current.range(of: .day, in: .month, for: monthStartDate)!
            let numDays = range.count
            let monthEndDate = getDateTime(day: numDays, month: monthNum, year: year, hour: 23, minute: 59)
            
            let startTimeStamp = String(monthStartDate.timeIntervalSince1970)
            let endTimeStamp = String(monthEndDate.timeIntervalSince1970)
            print(startTimeStamp)
            print(endTimeStamp)
            let query = db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Meetups").whereField("TimeStamp", isGreaterThanOrEqualTo: startTimeStamp).whereField("TimeStamp", isLessThanOrEqualTo: endTimeStamp)
                    query.getDocuments{(querySnapShot, error) in
                        if let error = error{
                            print("Error getting documents: \(error)")
                        }
                        else{
                            for doc in querySnapShot!.documents{
                                print(doc.data())
                                let meetupStatus = doc.get("MeetupHappened") as! String
                                if(meetupStatus == "true"){
                                    successfulMeetups += 1
                                }
                                totalMeetups += 1
                            }
                            self.yForYearly.append(totalMeetups)
                            self.xForYearly[monthNum] = successfulMeetups
                            print("adding")
                            if(self.xForYearly.count == 12){
                                self.createChart()
                            }
                            
                        }
                    }
        }
    }
    
    func createChart(){
        print(xForYearly)
        let sorted = xForYearly.sorted { $0.key < $1.key }
        print(sorted)
        let keysArraySorted = Array(sorted.map({ $0.key }))
        print(keysArraySorted)
        let valuesArraySorted = Array(sorted.map({ $0.value }))
        print(valuesArraySorted)
        view.addSubview(lineChartView)
        lineChartView.center(in: self.graphView)
        lineChartView.width(to: self.graphView, multiplier: 0.9)
        lineChartView.heightToWidth(of: self.graphView)
        setChart(dataPoints: monthsShort, values: valuesArraySorted)
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
        let marker: BalloonMarker = BalloonMarker(color: UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
         marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
      
        lineChartView.marker = marker
       
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.fillColor = UIColor(red: 180/255, green: 60/255, blue: 15/255, alpha: 1)
        chartDataSet.drawFilledEnabled = true // Draw the Gradient
        
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.circleColors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
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
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:monthsShort)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.animate(yAxisDuration: 0.5, easingOption: .linear)
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 15)
    }
}

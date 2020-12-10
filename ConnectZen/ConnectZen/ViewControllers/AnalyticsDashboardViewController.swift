//
//  AnalyticsDashboardViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/13/20.
//

import UIKit
import Charts
import TinyConstraints
import Firebase

class AnalyticsDashboardViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var AnalyticsStackView: UIStackView!
    @IBOutlet weak var monthYearSegControl: UISegmentedControl!
    let db = Firestore.firestore()
    var months: [String]!
    var yForYearly: [Int] = []
    var xForYearly: [Int] = []
    
    lazy var lineChartView: BarChartView = {
        let ChartView = BarChartView()
        ChartView.backgroundColor = .systemBackground
        return ChartView
    }()
    private lazy var firstViewController: MonthViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            var viewController = storyboard.instantiateViewController(withIdentifier: "MonthVC") as! MonthViewController
            self.add(asChildViewController: viewController)
            return viewController
        }()

        private lazy var secondViewController: YearViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            var viewController = storyboard.instantiateViewController(withIdentifier: "YearVC") as! YearViewController
            self.add(asChildViewController: viewController)
            return viewController
        }()
    
    @IBAction func didChangeMonthYearSegment(_ sender: UISegmentedControl){
        updateView()
    }
    
    private func add(asChildViewController viewController: UIViewController) {

            // Add Child View Controller
        addChild(viewController)

            // Add Child View as Subview
            containerView.addSubview(viewController.view)

            // Configure Child View
            viewController.view.frame = containerView.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // Notify Child View Controller
        viewController.didMove(toParent: self)
        }

        //----------------------------------------------------------------

        private func remove(asChildViewController viewController: UIViewController) {
            // Notify Child View Controller
            viewController.willMove(toParent: nil)

            // Remove Child View From Superview
            viewController.view.removeFromSuperview()

            // Notify Child View Controller
            viewController.removeFromParent()
        }
    
    private func updateView(){
        if monthYearSegControl.selectedSegmentIndex == 0{
            // Show month picker with monthly charts
            remove(asChildViewController: secondViewController)
            add(asChildViewController: firstViewController)
        }else{
            // Show year picker with yearly charts
            remove(asChildViewController: firstViewController)
                        add(asChildViewController: secondViewController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        
        /*view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: self.AnalyticsStackView)
        lineChartView.heightToWidth(of: self.AnalyticsStackView)
        
        let unitsSold = [5, 4, 3, 5, 2, 5, 5, 4, 5, 5, 2, 0]
        setChart(dataPoints: months, values: unitsSold)*/
        
    }
    
    
    
    
    
    
    
    
    func setChart(dataPoints: [String], values: [Int]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
                
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry( x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Units Sold")
        lineChartView.legend.font = UIFont.systemFont(ofSize: 18)
        let chartData = BarChartData()
        
        chartData.addDataSet(chartDataSet)
        
        chartData.setDrawValues(false)
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        lineChartView.data = chartData
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        lineChartView.xAxis.granularity = 1
        lineChartView.animate(yAxisDuration: 1.0, easingOption: .linear)
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 15)
        
        /*let formatter: ChartFormatter = ChartFormatter()
        for i in index{
                chartFormmater.stringForValue(Double(i), axis: xAxis)
            }

            xAxis.valueFormatter=chartFormmater
            chartView.xAxis.valueFormatter=xAxis.valueFormatter
        formatter.
        lineChartView.xAxis.valueFormatter =
        lineChartView.xAxis.granularity = 1*/
        
    }
}

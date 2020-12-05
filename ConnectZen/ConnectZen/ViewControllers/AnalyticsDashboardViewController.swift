//
//  AnalyticsDashboardViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/13/20.
//

import UIKit
import Charts
import TinyConstraints


class AnalyticsDashboardViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var AnalyticsStackView: UIStackView!
    var months: [String]!
    
    lazy var lineChartView: BarChartView = {
        let ChartView = BarChartView()
        ChartView.backgroundColor = .systemBackground
        return ChartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: self.AnalyticsStackView)
        lineChartView.heightToWidth(of: self.AnalyticsStackView)
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [5, 4, 3, 5, 2, 5, 5, 4, 5, 5, 2, 0]
        setChart(dataPoints: months, values: unitsSold)
        
    }
    
    func setChart(dataPoints: [String], values: [Int]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
                
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry( x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Successful meetups over the year 2020")
        lineChartView.legend.font = UIFont.systemFont(ofSize: 18)
        let chartData = BarChartData()
        
        chartData.addDataSet(chartDataSet)
        
        chartData.setDrawValues(true)
        chartDataSet.colors = [UIColor(red: 8/255, green: 232/255, blue: 222/255, alpha: 1)]
        lineChartView.data = chartData
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        lineChartView.xAxis.granularity = 1
        lineChartView.animate(yAxisDuration: 1.0, easingOption: .linear)
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 15)
                    lineChartView.chartDescription?.enabled = true
    
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

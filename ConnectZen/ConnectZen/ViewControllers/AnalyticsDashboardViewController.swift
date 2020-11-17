//
//  AnalyticsDashboardViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/13/20.
//

import UIKit
import Charts
import TinyConstraints


class AnalyticsDashboardViewController: UIViewController, ChartViewDelegate {
    
    lazy var lineChartView: LineChartView = {
        let ChartView = LineChartView()
        ChartView.backgroundColor = .systemTeal
        return ChartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

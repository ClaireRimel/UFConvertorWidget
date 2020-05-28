//
//  ViewController.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UIKit
import UFConvertorKit
import Charts

class CurrencyViewController: UIViewController, ChartViewDelegate {
    @IBOutlet var date: UILabel!
    @IBOutlet var uFValue: UITextField!
    @IBOutlet var clpValue: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var calculateButton: UIButton!
    @IBOutlet var graphContainerView: UIView!
    
    let model = RequestModel()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    lazy var lineChartView: LineChartView = {
        let chartview = LineChartView()
        chartview.backgroundColor = .clear
        chartview.rightAxis.enabled = false
        
        
        let yAxis = chartview.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor =  .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        chartview.xAxis.enabled = false

//        chartview.xAxis.labelPosition = .bottom
        chartview.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartview.xAxis.setLabelCount(6, force: false)
        chartview.xAxis.labelTextColor = .white
        chartview.xAxis.axisLineColor = .systemBlue
        
        
        chartview.animate(xAxisDuration: 1.0)
        
        return chartview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        toggleActivityIndicator(shown: false)
        
        uFValue.text = "1"
        
        // This function is called in viewDidLoad to ask the model the currency information of 1 EUR.
        request()
        
        lineChartView.frame = graphContainerView.frame
        lineChartView.frame.origin.y = 0
        graphContainerView.addSubview(lineChartView)
    }
    
    
    @IBAction func tappedGoButton(_ sender: Any) {
        toggleActivityIndicator(shown: true)
        view.endEditing(true)
        request()
    }
    
    @IBAction func dissmissKeyboard(_ sender: UITapGestureRecognizer) {
        uFValue.resignFirstResponder()
    }
    
    func request() {
        model.convert(from: uFValue.text ?? "") { (result) in
            self.toggleActivityIndicator(shown: false)
            switch result {
            case let .success(clpValue):
                let value = ConvertDouble.convertDoubleToCurrency(amount: clpValue, locale: Locale(identifier: "es_CL"))
                self.clpValue.text = value
                self.drawGraph()
                self.date.text = "\(self.dateFormatter.string(from: Date()) )"
            case let .failure(error):
                self.presentUIAlert(message: error.message)
            }
        }
    }
    
    private func toggleActivityIndicator(shown: Bool) {
        calculateButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func drawGraph() {
        let setChart = SetChart(series: model.series)
        let set1 = LineChartDataSet(entries: setChart.chartData(), label: "CLP")
        
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor = .systemRed
        set1.highlightLineWidth = 2
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
}

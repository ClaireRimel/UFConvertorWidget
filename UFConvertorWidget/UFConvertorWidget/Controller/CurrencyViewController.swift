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
    @IBOutlet var calculateButton: RoundButton!
    @IBOutlet var graphContainerView: UIView!
    @IBOutlet var valueSelectedLabel: UILabel!
    
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
        chartview.legend.enabled = false
        chartview.xAxis.enabled = false
        chartview.animate(xAxisDuration: 1.0)
        chartview.setScaleEnabled(false)
        
        return chartview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        toggleActivityIndicator(shown: false)
        uFValue.layer.cornerRadius = 17
        uFValue.text = "1"
        clpValue.layer.cornerRadius = 17
        // This function is called in viewDidLoad to ask the model the currency information of 1 EUR.
        request()
        
        lineChartView.delegate = self
        graphContainerView.addConstrained(subview: lineChartView)
        
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
        let valueY = ConvertDouble.convertDoubleToCurrency(amount: highlight.y, locale: Locale(identifier: "es_CL"))
        
        valueSelectedLabel.text = " \(valueY)"
    }
    
    
    func drawGraph() {
        let setChart = SetChart(series: model.series)
        let set1 = LineChartDataSet(entries: setChart.chartData(), label: "CLP")
        
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 3
        set1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        set1.highlightColor = #colorLiteral(red: 0.7908756137, green: 0.6883155107, blue: 0.47979635, alpha: 1)
        set1.highlightLineWidth = 2
        set1.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
        
    }
}

extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

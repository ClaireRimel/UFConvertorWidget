//
//  TodayViewController.swift
//  UFwidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UIKit
import NotificationCenter
import UFConvertorKit
import Charts

class TodayViewController: UIViewController, NCWidgetProviding, ChartViewDelegate {
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var changePriceLabel: UILabel!
    @IBOutlet var graphContainerView: UIView!
    
    let model = RequestModel()
    
    lazy var lineChartView: LineChartView = {
        let chartview = LineChartView()
        chartview.backgroundColor = .clear
        chartview.rightAxis.enabled = false
        chartview.leftAxis.enabled = false
        chartview.legend.enabled = false
        chartview.xAxis.enabled = false
        
        return chartview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        // Do any additional setup after loading the view.
        request()
        lineChartView.frame = graphContainerView.frame
        lineChartView.frame.origin.y = 0
        graphContainerView.addSubview(lineChartView)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func request() {
        model.convert(from: "1") { (result) in
            switch result {
            case let .success(clpValue):
                let value = ConvertDouble.convertDoubleToCurrency(amount: clpValue, locale: Locale(identifier: "es_CL"))
                self.priceLabel.text = value
                let diffenceValue = self.model.differenceValue()
                if diffenceValue < 0 {
                    self.changePriceLabel.text = "\(diffenceValue)"
                    self.changePriceLabel.textColor = .red
                } else if diffenceValue == 0 {
                    self.changePriceLabel.text = "\(diffenceValue)"
                } else {
                    self.changePriceLabel.text = "+ \(diffenceValue)"
                    self.changePriceLabel.textColor = .green
                }
                self.drawGraph()

            case .failure:
                self.priceLabel.text = "Error"
            }
        }
    }
    
    func drawGraph() {
        let setChart = SetChart(series: model.series)
        let set1 = LineChartDataSet(entries: setChart.chartData(), label: "CLP")
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 3
        set1.setColor(#colorLiteral(red: 0.96371454, green: 0.8006860614, blue: 0.4755767584, alpha: 1))
        set1.setDrawHighlightIndicators(false)
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
}

extension TodayViewController {
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
            graphContainerView.isHidden = true
            
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 200)

            graphContainerView.isHidden = false
            lineChartView.frame.size.height = 150
            lineChartView.frame.size.width = maxSize.width - 35
            lineChartView.animate(xAxisDuration: 1.0)
        }
    }
}

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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var changePriceLabel: UILabel!
    @IBOutlet var lineChartView: UIView!
    
    let model = RequestModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Do any additional setup after loading the view.
        request() 
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
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
                
            case .failure:
                self.priceLabel.text = "Error"
            }
        }
    }
}

extension TodayViewController {
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 150)
        }
    }
}

//
//  ViewController.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UIKit
import UFConvertorKit

class CurrencyViewController: UIViewController {
    @IBOutlet var date: UILabel!
    @IBOutlet var uFValue: UITextField!
    @IBOutlet var clpValue: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var calculateButton: UIButton!
    
    let model = RequestModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        uFValue.delegate = self
        toggleActivityIndicator(shown: false)
        
        uFValue.text = "1"
        
        // This function is called in viewDidLoad to ask the model the currency information of 1 EUR.
        request()
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
                let value = self.convertDoubleToCurrency(amount: clpValue, locale: Locale(identifier: "es_CL"))
                self.clpValue.text = value
                
            case let .failure(error):
                self.presentUIAlert(message: error.message)
            }
        }
    }
    
    private func toggleActivityIndicator(shown: Bool) {
        calculateButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
    func convertDoubleToCurrency(amount: Double, locale: Locale) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        return numberFormatter.string(from: NSNumber(value: amount))!
    }
    
}

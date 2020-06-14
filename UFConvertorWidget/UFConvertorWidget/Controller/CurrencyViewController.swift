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
    let notificationService = ScheduleNotification()
    
    
    lazy var localizedDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
    
    lazy var lineChartView: LineChartView = {
        let chartview = LineChartView()
        chartview.backgroundColor = .clear
        chartview.rightAxis.enabled = false
        chartview.legend.enabled = false
        chartview.xAxis.enabled = false
        chartview.animate(xAxisDuration: 1.0)
        chartview.setScaleEnabled(false)
        chartview.leftAxis.labelTextColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        chartview.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        
        return chartview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .dark
        calculateButton.setTitle(NSLocalizedString("Convert", comment: ""), for: .normal)
        
        view.setGradientBackground(colorOne: #colorLiteral(red: 0.08630939573, green: 0.1065077558, blue: 0.1527832747, alpha: 1), colorTwo: #colorLiteral(red: 0.1465604305, green: 0.152821064, blue: 0.259629786, alpha: 1), colorThree: #colorLiteral(red: 0.2043941617, green: 0.22268641, blue: 0.4445173442, alpha: 1))
        graphContainerView.setGradientBackground(colorOne: #colorLiteral(red: 0.9243683219, green: 0.6917772174, blue: 0.5800408721, alpha: 1), colorTwo: #colorLiteral(red: 0.9462508559, green: 0.7744612217, blue: 0.7079825997, alpha: 1), colorThree: #colorLiteral(red: 0.9896637797, green: 0.8509680629, blue: 0.7825837731, alpha: 1))
        graphContainerView.layer.cornerRadius = 16
        graphContainerView.clipsToBounds = true
        
        uFValue.text = "1"
        valueSelectedLabel.text = " "
        uFValue.tintColor = #colorLiteral(red: 0.1465604305, green: 0.152821064, blue: 0.259629786, alpha: 1)
        uFValue.clearButtonMode = .whileEditing
        
        toggleActivityIndicator(shown: false)
        setTextFieldUniformStyle(textField: uFValue)
        setTextFieldUniformStyle(textField: clpValue)
        
        // This function is called in viewDidLoad to ask the model the currency information of 1 UF.
        request()
        
        lineChartView.delegate = self
        uFValue.delegate = self
        graphContainerView.addConstrained(subview: lineChartView)
        graphContainerView.addSubview(lineChartView)
        
        //TODO: dothe permission after doing the firts convertion
        notificationService.askPermission(completion: { [weak self] error in
            if let error = error {
                self?.presentUIAlert(message: error.localizedDescription)
            } else {
                self?.notificationService.scheduleNotification()
            }
        })
    }
    
    func setTextFieldUniformStyle(textField: UITextField){
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: uFValue.frame.height))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 17
    }

    @IBAction func clpChanged(_ sender: UITextField) {
        if clpValue.text != nil {
                   let result =  model.cLPToUF(clp: clpValue.text ?? "1")
                    uFValue.text = "\(result)"
               } else {
                   self.presentUIAlert(message: "Error")
               }
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
                self.date.text = "\(self.localizedDate)"
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
        
        valueSelectedLabel.text = "\(valueY)"
    }
    
    func drawGraph() {
        let setChart = SetChart(series: model.series)
        let set1 = LineChartDataSet(entries: setChart.chartData(), label: "CLP")
        
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 3
        set1.setColor(#colorLiteral(red: 0.6375279427, green: 0.6473982334, blue: 0.7130541086, alpha: 1))
        set1.highlightColor = #colorLiteral(red: 0.08630939573, green: 0.1065077558, blue: 0.1527832747, alpha: 1)
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
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor, colorThree: UIColor) {
           let gradientLayer = CAGradientLayer()
           gradientLayer.frame = bounds
           gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor, colorThree.cgColor]
           gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
           gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)

           layer.insertSublayer(gradientLayer, at: 0)
       }
}

extension CurrencyViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Swift.Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 20
    }
}

//
//  ConvertDouble.swift
//  UFConvertorKit
//
//  Created by Claire on 28/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

public struct ConvertDouble {
    
   public static func convertDoubleToCurrency(amount: Double, locale: Locale) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: amount))!
    }
}

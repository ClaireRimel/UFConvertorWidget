//
//  CurrencyConvorterError.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

//typed errors
public enum CurrencyConvertorError: Error, Equatable {
    case error(NSError)
    case invalidResponseFormat
    case invalidInput
}

public extension CurrencyConvertorError {
     var message: String{
        switch self {
        case let .error(error):
            return error.localizedDescription
        case .invalidResponseFormat:
            return String.localized(key: "Invalid response format")
        case .invalidInput:
            return String.localized(key: "Invalid input")
        }
    }
}

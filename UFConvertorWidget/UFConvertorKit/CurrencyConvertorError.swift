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
    case requestError(NSError)
    case invalidResponseFormat
    case invalidInput
}

public extension CurrencyConvertorError {
     var message: String{
        switch self {
        case let .requestError(error):
            return error.localizedDescription
        case .invalidResponseFormat:
            return "El formato de respuesta del servidor no es válido"
        case .invalidInput:
            return "Ingrese una cantidad válida"
        }
    }
}

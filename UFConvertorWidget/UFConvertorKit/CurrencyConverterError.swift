//
//  CurrencyConverterError.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

//typed errors
public enum CurrencyConverterError: Error, Equatable {
    case requestError(NSError)
    case invalidResponseFormat
    case usdRateNotFound
    case invalidInput
}

public extension CurrencyConverterError {
     var message: String{
        switch self {
        case let .requestError(error):
            return error.localizedDescription
        case .invalidResponseFormat:
            return "Le format de réponse du serveur est invalide "
        case .usdRateNotFound:
            return "La devise USD n'est pas disponible"
        case .invalidInput:
            return "Entrez un montant valide"
        }
    }
}

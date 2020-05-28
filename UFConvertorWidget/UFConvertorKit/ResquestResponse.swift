//
//  Resquest.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

struct RequestResponse: Codable {
    let serie: [Serie]
}

public struct Serie: Codable {
    let date: String
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case date = "fecha"
        case value = "valor"
    }
}

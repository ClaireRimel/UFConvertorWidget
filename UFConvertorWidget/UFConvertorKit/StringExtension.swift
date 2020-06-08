//
//  StringExtension.swift
//  UFConvertorKit
//
//  Created by Claire on 08/06/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

extension String {

    static func localized(key: String, withComment comment: String = "") -> String {
        return NSLocalizedString(key, bundle: Bundle.module, comment: comment)
    }
}

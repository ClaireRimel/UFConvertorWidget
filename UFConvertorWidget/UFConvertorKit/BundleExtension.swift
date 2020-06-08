//
//  BundleExtension.swift
//  UFConvertorKit
//
//  Created by Claire on 08/06/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

extension Bundle {

    private static let bundleID = "com.ClaireSivadier.UFConvertorKit"

    static var module: Bundle {
        return Bundle(identifier: bundleID) ?? .main
    }

}

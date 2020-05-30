//
//  RoundedButton.swift
//  UFConvertorWidget
//
//  Created by Claire on 29/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 17
    }
}

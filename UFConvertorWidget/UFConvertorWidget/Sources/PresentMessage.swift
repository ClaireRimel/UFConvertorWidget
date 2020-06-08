//
//  PresentMessage.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentUIAlert(message: String) {
        let alertVC = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

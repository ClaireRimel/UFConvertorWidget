//
//  RequestInterfaceProtocol.swift
//  UFConvertorKit
//
//  Created by Claire on 30/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

// Auxiliar protocol that copies URLSession's dataTask function signature for testing purposes(to define mock types that conform to this protocol)
public protocol RequestInterface {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: RequestInterface {}

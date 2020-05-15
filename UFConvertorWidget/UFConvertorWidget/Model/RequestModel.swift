//
//  RequestModel.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

final class RequestModel {
    
    var series: [Serie] = []
    
    func openSessionRequest(then: @escaping (Result<RequestResponse, Error>) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateToday = dateFormatter.string(from: Date())
        
//        let path = "/api/uf/\(dateToday)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mindicador.cl"
        components.path = "/api/uf/\(dateToday)"


        
        
        //Gets URL object based on given components
        let url = components.url!
        print(url)
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        
        //TODO: wrap code inside a Result type for better error handling
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    then(.failure(error))
                }
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                //TODO: handle error
                return
            }
            
            if statusCode == 200 {
                //ok
                guard let data = data,
                    let decodedResponse = try?
                        JSONDecoder().decode(RequestResponse.self, from: data) else {
                            DispatchQueue.main.async {
                                then(.failure(error!))
                            }
                            return
                }
                self.series = decodedResponse.serie
                DispatchQueue.main.async {
                    then(.success(decodedResponse))
                    print(decodedResponse)
                }
                
            } else {
                guard let data = data,
                    let decodedResponse = try?
                        JSONDecoder().decode(RequestResponse.self, from: data) else {
                            DispatchQueue.main.async {
                                then(.failure(error!))
                            }
                            return
                }
                
                DispatchQueue.main.async {
                    let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: decodedResponse.serie.description])
                    then(.failure(error))
                }
            }
        })
        task.resume()
    }
}

//
//  RequestModel.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

final class RequestModel {
    
    enum RequestDateRequired: Equatable {
        case required
        case notRequired
    }
    
    struct LatestRateAndDate {
        var clpRate: Double
        var requestDate: String
    }
    
    var latestRateAndDate: LatestRateAndDate?
    
    var series: [Serie] = []
    
    func convert(from: String, then: @escaping (Result<Double, CurrencyConverterError>) -> Void) {
        
        // Verify if the String can be converter to a Double, if not, a error message will be displayed.
        guard let value = convertToDouble(from: from)
            else {
                then(.failure(.invalidInput))
                return
        }
        
        // Verify if the latest request was made the same day, to do the conversion with the latest known rate received, otherwise, to process to a new request
        if let latestRateAndDate = latestRateAndDate, wasRequestMadeToday(requestDate: latestRateAndDate.requestDate) {
            
            let clpRate = value * latestRateAndDate.clpRate
            DispatchQueue.main.async {
                then(.success(clpRate))
            }
        } else {
            request(required:.required, then: { (result) in
                switch result {
                case .success:
                    self.convert(from: from, then: then)
                case let .failure(error):
                    //TODO: HANDLE ERROR
                    break
                }
            })
        }
    }
    
    func request(required: RequestDateRequired,  then: @escaping (Result<RequestResponse, Error>) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateToday = dateFormatter.string(from: Date())
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mindicador.cl"
        
        if required == .required {
            components.path = "/api/uf/\(dateToday)"
        } else {
            components.path = "/api/uf"
        }

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
                self.latestRateAndDate = LatestRateAndDate(clpRate: decodedResponse.serie[0].value , requestDate:  decodedResponse.serie[0].date)

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
    
    // Use to format today's date and compare it with a given date
      func wasRequestMadeToday(requestDate: String) -> Bool {
//        "2020-05-15T04:00:00.000Z"
        
        
//          let date = Date()
          let format = DateFormatter()
          format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let dateToCompare = format.date(from: requestDate) {
            if Calendar.current.compare(Date(), to: dateToCompare, toGranularity: .day) == .orderedSame {
                return true
            }
        }
        return false
      }
    
    // Use to convert a curreny to a Double
       func convertToDouble(from currency: String)-> Double? {
           return Double(currency)
       }
}

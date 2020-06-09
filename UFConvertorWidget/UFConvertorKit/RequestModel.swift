//
//  RequestModel.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

public final class RequestModel {
    
    struct LatestRateAndDate {
        var clpRate: Double
        var requestDate: String
    }
    
    var latestRateAndDate: LatestRateAndDate?
    
    public let session: RequestInterface

    public var series: [Serie] = []
    
    
    public init(session: RequestInterface = URLSession.shared){
        self.session = session
    }
    
    public func convert(from: String, then: @escaping (Result<Double, CurrencyConvertorError>) -> Void) {
        let fromRemplaceWithDot  = from.replacingOccurrences(of: ",", with: ".")
        // Verify if the String can be converter to a Double, if not, a error message will be displayed.
        guard let value = convertToDouble(from: fromRemplaceWithDot)
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
            request(  then: { (result) in
                switch result {
                case .success:
                    self.convert(from: from, then: then)
                case let .failure(error):
                    then(.failure(error))
                }
            })
        }
    }
    
    func request(then: @escaping (Result<RequestResponse, CurrencyConvertorError>) -> Void) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mindicador.cl"
        components.path = "/api/uf"
        
        //Gets URL object based on given components
        let url = components.url!
        print(url)
        
        //now create the URLRequest object using the url object
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        //TODO: wrap code inside a Result type for better error handling
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                //ok
                guard let data = data,
                    let decodedResponse = try?
                        JSONDecoder().decode(RequestResponse.self, from: data) else {
                            DispatchQueue.main.async {
                                then(.failure(.invalidResponseFormat))
                            }
                            return
                }
                
                self.series = decodedResponse.serie
                self.latestRateAndDate = LatestRateAndDate(
                    clpRate: decodedResponse.serie[0].value,
                    requestDate:  decodedResponse.serie[0].date)
                
                DispatchQueue.main.async {
                    then(.success(decodedResponse))
                    print(decodedResponse)
                }
            } else {
                let nserror: NSError = error != nil ? error! as NSError : NSError(domain: "UFConvertorKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "request error"])
                
                DispatchQueue.main.async {
                    then(.failure(.requestError(nserror)))
                }
            }
        })
        task.resume()
    }
    
    // Use to format today's date and compare it with a given date
    func wasRequestMadeToday(requestDate: String) -> Bool {
        let format = DateFormatter()
        format.timeZone = TimeZone(abbreviation: "CLT")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let localDate =  format.string(from: Date())
        
        var calender = Calendar.current
        calender.timeZone = TimeZone.init(abbreviation: "CLT") ?? TimeZone.current

        if let dateToCompare = format.date(from: requestDate),
            let todayDate = format.date(from: localDate) {
            
            let result = calender.compare(dateToCompare, to: todayDate, toGranularity: .day)
            if result == .orderedSame {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    // Use to convert a curreny to a Double
    func convertToDouble(from currency: String)-> Double? {
        return Double(currency)
    }
    
    public func differenceValue(day1: Double, day2: Double) -> Int {
        let difference = day1 - day2
        return Int(difference)
    }
}

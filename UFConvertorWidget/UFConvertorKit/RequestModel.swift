//
//  RequestModel.swift
//  UFConvertorWidget
//
//  Created by Claire on 15/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation

public final class RequestModel {
     
    public let session: RequestInterface
    
    public var series: [Serie] = []
    
    let coreDataService: CoreDataService = CoreDataService()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "CLT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    lazy var requestDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "CLT")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
    
    
    
    //fetch all Serie in CoreData
    //if data exists, verify if there's data for today
    //if there is, use it. No server request is required
    //else. Do server request.
    
    //On Server response
    //Store all information in Core Data
    
    public init(session: RequestInterface = URLSession.shared){
        self.session = session
    }
    
    public func convert(from: String, then: @escaping (Result<Double, CurrencyConvertorError>) -> Void) {
        let fromRemplaceWithDot  = from.replacingOccurrences(of: ",", with: ".")
        // Verify if the String can be converter to a Double, if not, a error message will be displayed.
        guard let value = Double(fromRemplaceWithDot)
            else {
                then(.failure(.invalidInput))
                return
        }
        
        // Verify if the latest request was made the same day, to do the conversion with the latest known rate received, otherwise, to process to a new request
        do {
            if let todaySerie = try fetchDataForDate(date: .today) {
                // There is information for today
                let clpRate = value * todaySerie.value
                DispatchQueue.main.async {
                    then(.success(clpRate))
                }
            } else {
                let timeFrame: DataTimeFrame
                if try fetchDataForDate(date: .yesterday) != nil {
                    timeFrame = .today
                } else {
                    timeFrame = .lastMonth
                }
                request(timeFrame: timeFrame, then: { (result) in
                    switch result {
                    case .success:
                        self.convert(from: from, then: then)
                    case let .failure(error):
                        then(.failure(error))
                    }
                })
            }
        } catch {
            then(.failure(.error(error as NSError)))
        }
    }
    
    enum FetchableDate: Equatable {
        case today, yesterday
    }
    
    func fetchDataForDate(date: FetchableDate) throws -> Serie? {
        let dateParameter: Date
        switch date {
        case .today:
            dateParameter = Date()
        case .yesterday:
            guard let yesterdayDate = dateFormatter.calendar.date(byAdding: .day, value: -1, to: Date()) else {
                return nil
            }
            dateParameter = yesterdayDate
        }
        
        let dateString =  dateFormatter.string(from: dateParameter)
        let predicate = NSPredicate(format: "date == %@", dateString)
        let result = try coreDataService.fetchSeries(with: predicate, fetchLimit: 1)
        return result?.first
    }
}

extension RequestModel {
    
    enum DataTimeFrame: Equatable {
        case today, lastMonth
    }
    
    func request(timeFrame: DataTimeFrame, then: @escaping (Result<RequestResponse, CurrencyConvertorError>) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mindicador.cl"
        
        switch timeFrame {
        case .today:
            components.path = "/api/uf/\(requestDateFormatter)"
        case .lastMonth:
            components.path = "/api/uf"
        }
        
        //Gets URL object based on given components
        let url = components.url!
        print(url)
        
        //now create the URLRequest object using the url object
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
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
                
                self.series = decodedResponse.series
                
                do {
                    switch timeFrame {
                    case .today:
                        //We asume that the first element of the series array represents todays date
                        let todaySerie = decodedResponse.series[0]
                        try self.coreDataService.save(series: [todaySerie])
                        
                    case .lastMonth:
                       try self.coreDataService.delete()
                       try self.coreDataService.save(series: decodedResponse.series)
                    }
                    
                    DispatchQueue.main.async {
                        then(.success(decodedResponse))
                        print(decodedResponse)
                    }
                    
                } catch {
                    then(.failure(.error(error as NSError)))
                }
            } else {
                let nserror: NSError = error != nil ? error! as NSError : NSError(domain: "UFConvertorKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "request error"])
                
                DispatchQueue.main.async {
                    then(.failure(.error(nserror)))
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
    
    public func differenceValue(day1: Double, day2: Double) -> Double {
        let difference = day1 - day2
        return Double(difference)
    }
}

extension RequestModel {
    
    public func cLPToUF(clp: String) -> Double {
        let fromRemplaceWithDot  = clp.replacingOccurrences(of: ",", with: ".")

        guard let clpValue = Double(fromRemplaceWithDot), series.first != nil  else {
            return 0
        }

        let result = (clpValue * 1)/series[0].value

        return result
    }
}

//
//  UFConvertorKitTests.swift
//  UFConvertorKitTests
//
//  Created by Claire on 30/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import XCTest
@testable import UFConvertorKit

class UFConvertorKitTests: XCTestCase {
    
    var sut: RequestModel!
    var requestMock: RequestModelMock!
    
    override func setUp() {
        requestMock = RequestModelMock()
        sut = RequestModel(session: requestMock)
    }
    
    
    override func tearDown() {
        
    }

    func testInvalidInputCharacter() {
        // Given
        let input = "A"
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidInput))
            expectation.fulfill()
            
        }
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidInputDoubleComma() {
        // Given
        let input = "2.."
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.invalidInput))
            expectation.fulfill()
        }
        //wait...
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformCalculationWithExistingData() {
        // Given
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = format.string(from: date)
        
        sut.latestRateAndDate = RequestModel.LatestRateAndDate(clpRate: 2.0, requestDate: formattedDate)
        let input = "4"
        let expectation = self.expectation(description: "")
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .success(8))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWasntRequestMadeToday() {
        // Given
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = format.string(from: yesterday())

        // When
        let result = sut.wasRequestMadeToday(requestDate: date)

        //Then
        XCTAssertFalse(result)
    }
    
    func testDifferenceValue(){
        //Given
        let day1 = 23.0
        let day2 = 24.0
        //When
        let result = sut.differenceValue(day1: day1, day2: day2)
        //Then
        XCTAssertEqual(result, -1)
    }

    func testPerformCalculationWithoutExistingData(){
        //Given
        sut.latestRateAndDate = nil
        let input = "4"
        let expectation = self.expectation(description: "")
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        requestMock.response = RequestResponse(serie: [Serie(date: format.string(from: Date()), value: 2.0)])
        
        //When
        sut.convert(from: input) { (result) in
            //Then
            XCTAssertEqual(result, .success(8))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidResponseFormat() {
         // Given
         sut.latestRateAndDate = nil
         let input = "4"
         let expectation = self.expectation(description: "")
         
         requestMock.data = Data()
         
         // When
         sut.convert(from: input) { (result) in
             // Then
             XCTAssertEqual(result, .failure(.invalidResponseFormat))
             expectation.fulfill()
         }
         waitForExpectations(timeout: 1, handler: nil)
     }
    
    func testRequestsDataIfTheresNoDataAndInputIsValid() {
        // Given
        sut.latestRateAndDate = nil
        let input = "2"
        
        // When
        sut.convert(from: input) {_ in}
        
        //Then
        XCTAssertEqual(self.requestMock.request?.httpMethod, "GET")
        
        let url = requestMock.request?.url?.absoluteString
        
        let urlComponents = URLComponents(string: url!)
        XCTAssertEqual(urlComponents?.scheme, "https")
        XCTAssertEqual(urlComponents?.host, "mindicador.cl")
        XCTAssertEqual(urlComponents?.path, "/api/uf")
    }
    
    func testInvalideStatusCode() {
        // Given
        let input = "2"
        let expectation = self.expectation(description: "")
        let error = NSError(domain: "", code: 0, userInfo: nil)

        requestMock.error = error
        requestMock.statusCode = 000
        
        // When
        sut.convert(from: input) { (result) in
            // Then
            XCTAssertEqual(result, .failure(.requestError(error)))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}

extension UFConvertorKitTests {
    
    func yesterday() -> Date {
       var dateComponents = DateComponents()
       dateComponents.setValue(-1, for: .day) // -1 day

       let now = Date() // Current date
       let yesterday = Calendar.current.date(byAdding: dateComponents, to: now) // Add the DateComponents
       return yesterday!
    }
    
    final class  RequestModelMock: RequestInterface {
        
        var request: URLRequest?
        
        var response: RequestResponse?
        
        var error: Error?
        
        var data: Data?
        
        var statusCode: Int = 200
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.request = request
            
            let urlResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: statusCode,
                                              httpVersion: nil,
                                              headerFields: nil)
            
            if let response = response {
                let data = try! JSONEncoder().encode(response)
                completionHandler(data, urlResponse, nil)
                
            } else {
                completionHandler(data, urlResponse, error)
            }
            
            if #available(iOS 13, *) {
                return URLSession.shared.dataTask(with: request)
            } else {
                return URLSessionDataTask()
            }
        }
    }
}

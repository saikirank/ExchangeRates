//
//  RequestHandler.swift
//  ExchangeRates
//
//  Created by SaikiranK on 10/02/21.
//  Copyright © 2021 Saikiran Komirishetty. All rights reserved.
//

import Foundation

public struct Constants {
    static let BaseURL = "http://apilayer.net/api/live?access_key=%@&currencies=&source=USD&format=1"
    static let accessKey = "bbdc831ce31131096095a30795d8b43e"
    
}

class  RequestHandler {
    var currentTask: URLSessionDataTask?
    
    static let sessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForResource = 60
        return sessionConfiguration
    }()
    
    static let session  = URLSession(configuration: sessionConfiguration)
    
    func getExchangeRates(successHandler: @escaping (ExchangeRates?, Error?) -> Void,
                          failureHandler: @escaping  (ExchangeRates?, Error?) -> Void) {
        
        let urlString = String(format: Constants.BaseURL, Constants.accessKey)
        
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            RequestHandler.session.dataTask(with: urlRequest) { (data, response, error) in
                
                if let error = error {
                    failureHandler(nil, error)
                } else {
                    
                    guard let data = data else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let exchangeRates = try decoder.decode(ExchangeRates.self, from: data)
                        successHandler(exchangeRates, nil)
                    } catch {
                        failureHandler(nil, nil)
                    }
                }
            }.resume()
            
        }
    }
    
}

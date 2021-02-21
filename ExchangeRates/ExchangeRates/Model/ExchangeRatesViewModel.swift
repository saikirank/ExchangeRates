//
//  ExchangeRatesViewModel.swift
//  ExchangeRates
//
//  Created by SaikiranK on 13/02/21.
//  Copyright © 2021 Saikiran Komirishetty. All rights reserved.
//

import Foundation

public class ExchangeRatesViewModel {
    
    let quotes: Box<[String: Double]?> = Box(nil)  //no quotes initially
    let arrayAllCurrencies: Box<[String]> = Box([])  //Empty initially
    let filteredQuotes: Box<[String: Double]?> = Box(nil)  //no filteredQuotes initially
    let errorDesc: Box<String?> = Box(nil)
    
    
    init() {
        getExchangeRates()
        //fetch quotes for every 30 minutes..
        //TO DO: Need to do background fetch along with this
        _ = Timer.scheduledTimer(timeInterval: 30 * 60, target: self, selector: #selector(getExchangeRates), userInfo: nil, repeats: true)
    }
    
    @objc func getExchangeRates() {
        RequestHandler().getExchangeRates(successHandler: { (rates, error) in
            
            if let exchangeRates = rates
            {
                let keys = exchangeRates.quotes.keys.sorted {$0 < $1}
                self.arrayAllCurrencies.value = Array(keys)
                self.quotes.value = exchangeRates.quotes
                self.filteredQuotes.value = exchangeRates.quotes
            }
        }, failureHandler: { (rates, error) in
            self.errorDesc.value = error?.localizedDescription
        })
    }
    
    func getDisplayCurrency(forTitle title: String) -> String {
        title.replaceRange(of: "USD", with: "")
    }
    
    func filterQuotesBasedonText(text: String) {
        filteredQuotes.value = text.isEmpty ? quotes.value : quotes.value?.filter({(quote) -> Bool in
            // If dataItem matches the searchText, return true to include it
            
            return quote.key.range(of: text, options: .caseInsensitive) != nil
        })
    }
    
    func resetFilter() {
        filteredQuotes.value = quotes.value
    }
    
    func getDisplayAmount(forAmount amountText: String, selectedCurrency: String, selectedSourceCurrency: Double) -> String {
        let rate = (self.filteredQuotes.value?[selectedCurrency]!)!
        let calculatedRate = (Double(amountText) ?? 1.0) * ((rate) / selectedSourceCurrency)
        return String(format: "%.2f", calculatedRate)
    }
}

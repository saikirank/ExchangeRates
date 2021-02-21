//
//  LandingViewController.swift
//  ExchangeRates
//
//  Created by SaikiranK on 10/02/21.
//  Copyright © 2021 Saikiran Komirishetty. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    @IBOutlet weak var sourceCurrencyTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var listTableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var exchangeRatesViewModel: ExchangeRatesViewModel!
    
    var filteredQuotes: [String: Double]?
    
    var allQuotes: [String: Double]?
    
    var filteredCurrencies:[String]?
    var arrayAllCurrencies:[String]?
    
    let pickerView = UIPickerView()
    var selectedSourceCurrency = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewModel()
        setupSourceCurrencyTextField()
        setupAmountTextField()
        
        //Dynamic row height
        listTableview.rowHeight = UITableView.automaticDimension
        listTableview.estimatedRowHeight = 50
    }
}

//Setup ViewModel
extension LandingViewController {
    func setupViewModel() {
        exchangeRatesViewModel = ExchangeRatesViewModel()
        
        exchangeRatesViewModel.quotes.bind { [weak self] quotes in
            guard let self = self, let quotes = quotes else {
                return
            }
            self.allQuotes = quotes
            self.filteredCurrencies = Array(quotes.keys)
            self.filteredCurrencies = self.filteredCurrencies?.sorted {$0 < $1}
        }
        
        exchangeRatesViewModel.arrayAllCurrencies.bind { [weak self] arrayAllCurrencies in
            self?.arrayAllCurrencies = arrayAllCurrencies
        }
        
        exchangeRatesViewModel.filteredQuotes.bind { [weak self] filteredQuotes in
            self?.filteredQuotes = filteredQuotes
            guard let self = self, let filteredQuotes = filteredQuotes else {
                return
            }
            DispatchQueue.main.async {
                self.filteredCurrencies = Array(filteredQuotes.keys)
                self.filteredCurrencies = self.filteredCurrencies?.sorted {$0 < $1}
                self.listTableview.reloadData()
                self.pickerView.reloadAllComponents()
            }
        }
        
        exchangeRatesViewModel.errorDesc.bind { [weak self] message in
            if message?.isEmpty == false {
                self?.showAlert(msg: message ?? "Unable to process")
            }
        }
    }
}


//UI setup
extension LandingViewController {
    func setupSourceCurrencyTextField() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.sourceCurrencyTextField.inputAccessoryView = doneToolbar
        self.pickerView.delegate = self
        self.sourceCurrencyTextField.inputView = self.pickerView
    }
    func setupAmountTextField() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.amountDoneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.amountTextField.inputAccessoryView = doneToolbar
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(
            title: nil,
            message: msg,
            preferredStyle: .alert)
        //2
        let alertAction = UIAlertAction(
            title: "Ok",
            style: .default) {  _ in
        }
        alert.addAction(alertAction)
        //3
        present(alert, animated: true)
        
    }
}

// Button event handling
extension LandingViewController {
    
    @objc func amountDoneButtonAction(){
        self.amountTextField.resignFirstResponder()
        self.listTableview.reloadData()
    }
    @objc func doneButtonAction(){
        self.sourceCurrencyTextField.resignFirstResponder()
        let selectedValue = self.arrayAllCurrencies?[self.pickerView.selectedRow(inComponent: 0)].replaceRange(of: "USD", with: "")
        self.sourceCurrencyTextField.text = selectedValue
        self.selectedSourceCurrency = self.allQuotes?[self.arrayAllCurrencies![self.pickerView.selectedRow(inComponent: 0)]] ?? 1.0
        self.listTableview.reloadData()
    }
}

extension LandingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        exchangeRatesViewModel.filterQuotesBasedonText(text: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        exchangeRatesViewModel.resetFilter()
    }
}

extension LandingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayAllCurrencies?.count ?? 0
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        exchangeRatesViewModel.getDisplayCurrency(forTitle: self.arrayAllCurrencies![row])
    }
}
extension LandingViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCurrencies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RatesTableViewCell", for: indexPath) as? RatesTableViewCell else {
            fatalError("RatesTableViewCell not found")
        }
        cell.currencyName.text = exchangeRatesViewModel.getDisplayCurrency(forTitle: self.filteredCurrencies![indexPath.row])
        
        cell.amount.text = exchangeRatesViewModel.getDisplayAmount(forAmount: self.amountTextField.text!, selectedCurrency: self.filteredCurrencies![indexPath.row], selectedSourceCurrency: selectedSourceCurrency)
        return cell
    }
}


extension String {
    
    public func replaceRange(of pattern:String,
                             with replacement:String) -> String {
        if let range = self.range(of: pattern){
            return self.replacingCharacters(in: range, with: replacement)
        }else{
            return self
        }
    }
}

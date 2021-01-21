//
//  ViewController.swift
//  iGoogleChrome
//
//  Created by Quentin SCHEIDT Dev on 20/01/2021.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var currencyInTextField: UITextField!
    @IBOutlet weak var currencyOutTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateStartDatePicker: UIDatePicker!
    @IBOutlet weak var dateEndDatePicker: UIDatePicker!
    
    @IBOutlet weak var convertButton: UIButton!
    
    private weak var currentInput: UITextField?
    
    private var items: [Currency] = []
    private var availableList: [Currency] = []
    
    private var pickerIn: UIPickerView = UIPickerView()
    private var pickerOut: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let date = Date()
        dateEndDatePicker.maximumDate = date
        dateStartDatePicker.maximumDate = date
        
        loadCurrencies()
        
        // Picker 1
        pickerIn.dataSource = self
        pickerIn.delegate = self
        // Picker 2
        pickerOut.dataSource = self
        pickerOut.delegate = self
        
        currencyInTextField.delegate = self
        currencyOutTextField.delegate = self
        
        currencyInTextField.inputView = pickerIn
        currencyOutTextField.inputView = pickerOut
        
        dismissPickerView(field: currencyInTextField)
        dismissPickerView(field: currencyOutTextField)
    }
    
    func dismissPickerView(field: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    @IBAction func onClick() {
        let currencyIn: String = currencyInTextField.text ?? ""
        let currencyOut: String = currencyOutTextField.text ?? ""
        
        if currencyIn.isEmpty || currencyOut.isEmpty {
            showDialog(title: "Champs manquant", message: "Il faut remplir les champs FROM et TO")
            return
        }
        
        let amount: Double = Double(amountTextField.text ?? "1.0") ?? 1.0
        if amount < 0.1 {
            showDialog(title: "Valeur incorrect", message: "Le montant doit être au minimum 0.1")
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "chartVC") as! ChartViewController
        vc.setCurrencyIn(value: currencyIn)
        vc.setCurrencyOut(value: currencyOut)
        vc.setAmount(value: amount)
        vc.setStartDate(value: dateStartDatePicker.date)
        vc.setEndDate(value: dateEndDatePicker.date)
        guard let navController = navigationController else {
            showDialog(title: "Erreur", message: "View introuvable")
            return
        }
        navController.pushViewController(vc, animated: true)
    }
    
    func showDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                        switch action.style{
                                        case .default:
                                            print("default")
                                            
                                        case .cancel:
                                            print("cancel")
                                            
                                        case .destructive:
                                            print("destructive")
                                            
                                            
                                        }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadCurrencies(){
        AF.request("https://api.frankfurter.app/currencies").responseJSON {
            response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                for (key, value) in response {
                    var bleuh:Currency = Currency()
                    bleuh.key = String(describing: key)
                    bleuh.value = String(describing: value)
                    
                    self.items.append(bleuh)
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let inputField = currentInput else {
            return
        }
        inputField.text = availableList[row].key
    }
    
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableList[row].key
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentInput = textField
        weak var otherInput = (textField == currencyInTextField) ? currencyOutTextField : currencyInTextField
        let filtered = items.filter { item in
            return item.key != otherInput?.text
        }
        
        availableList = filtered
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentInput = nil
    }
    
}


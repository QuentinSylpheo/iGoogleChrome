//
//  ChartViewController.swift
//  iGoogleChrome
//
//  Created by Alexis Delhaie on 21/01/2021.
//

import UIKit
import Alamofire
import Charts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var currencyInLabel: UILabel!
    @IBOutlet weak var currencyOutLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var barChartView: LineChartView!
    
    private var currencyIn: String?
    private var currencyOut: String?
    private var amount: Double?
    private var startDate: Date?
    private var endDate: Date?
    
    private var listOfRates: [Rate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        currencyInLabel.text = currencyIn ?? "---"
        currencyOutLabel.text = currencyOut ?? "---"
        loadChart()
    }
    
    func setCurrencyIn(value: String) {
        currencyIn = value
    }
    
    func setCurrencyOut(value: String) {
        currencyOut = value
    }
    
    func setAmount(value: Double) {
        amount = value
    }
    
    func setStartDate(value: Date) {
        startDate = value
    }
    
    func setEndDate(value: Date) {
        endDate = value
    }
    
    private func loadChart(){
        guard let currencyFrom = currencyIn else {
            return
        }
        guard let currencyTo = currencyOut else {
            return
        }
        guard let sureStartDate = startDate else {
            return
        }
        guard let sureEndDate = endDate else {
            return
        }
        
        let parameters: Parameters = [
            "amount": String(amount ?? 1),
            "from": currencyFrom,
            "to": currencyTo
        ]
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let url = "https://api.frankfurter.app/\(dateFormat.string(from: sureStartDate))..\(dateFormat.string(from: sureEndDate))"
        AF.request(url, parameters: parameters).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                let rates = response["rates"] as! NSDictionary
                for (key, value) in rates {
                    let r = value as! NSDictionary
                    let val = Double((r[currencyTo] as? String) ?? "0") ?? 0.0
                    let d = dateFormat.date(from: key as! String) ?? Date()
                    let rate: Rate = Rate(date: d, value: val)
                    self.listOfRates.append(rate)
                }
                print(self.listOfRates.count)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }

}

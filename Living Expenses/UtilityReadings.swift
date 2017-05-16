//
//  UtilityReadings.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 15/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

class UtilityReadingsView: UIViewController {
//MARK: Variables
    var billID: Int!
    var billInfo: BillInformation!
    
//MARK: Outlets
    @IBOutlet weak var billName: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var utilityTypeLabel: UILabel!
    @IBOutlet weak var costPerUnitLabel: UILabel!
    @IBOutlet weak var dailyCostLabel: UILabel!
 
//MARK: IBActions

    @IBAction func returnButton(_ sender: UIBarButtonItem) {
        dismissViewController()
    }
    
//MARK: Functions
    func setLabels() {
        formatter.numberStyle = NumberFormatter.Style.currency
        
        billName.text = billInfo.billName
        startDateLabel.text = billInfo.startDate
        endDateLabel.text = billInfo.endDate
        
        utilityTypeLabel.text = billInfo.utilitytype
        costPerUnitLabel.text = formatter.string(from: billInfo.costperunit)
        dailyCostLabel.text = formatter.string(from: billInfo.dailycost)
    }
    
    func dismissViewController() {
        //temp
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    
//MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Utility Readings"
        
        if let id = billID {
            DBManager.shared.loadBill(withID: id, completionHandler: { (bill) in
                DispatchQueue.main.async {
                    if bill != nil {
                        self.billInfo = bill
                        self.setLabels()
                    }
                }
            })
        }

    }
}

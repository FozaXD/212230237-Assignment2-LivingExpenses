//
//  BillDetails.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 3/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

class BillDetailsView: UIViewController {
//MARK: Variables
    var billID: Int!
    var billInfo: BillInformation!
    var segueFromController : String!
    
//MARK: Outlets
    @IBOutlet weak var billName: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var totalPaidLabel: UILabel!

//MARK: Actions
    @IBAction func removeBill(_ sender: UIButton) {
        removeBillfromDB()
        dismissViewController()
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismissViewController()
    }
    
//MARK: Functions
    func didScreenEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        dismissViewController()
    }
    
    func dismissViewController() {
        if segueFromController == "HomeView"
        {
            self.performSegue(withIdentifier: "returnFromBillViewToHomeSegueId", sender: nil)
        }
        else if segueFromController == "CalendarView"
        {
            self.performSegue(withIdentifier: "returnFromBillViewToCalendarSegueId", sender: nil)
            
        }
    }
    
    func setLabels() {
        billName.text = billInfo.billName
        startDateLabel.text = billInfo.startDate
        endDateLabel.text = billInfo.endDate
        costLabel.text = "$" + String(describing: billInfo.cost.decimalValue)
        totalPaidLabel.text = "$" + String(describing: billInfo.paid.decimalValue)
    }
    
    func removeBillfromDB()
    {
        let errorBillName: String = "Could not remove bill: " + billInfo.billName
        if DBManager.shared.deleteBill(withID: billInfo.billID) == false
        {
            let alertController = UIAlertController(title: "Error", message: errorBillName, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
            }
        }
    }
  
//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  Home.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 29/4/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

//#MARK: Struct
struct BillInformation {
    var billID: Int!
    var billName: String!
    var startDate: String!
    var endDate: String!
    var uec: Bool!
    var cost: NSNumber!
    var paid: NSNumber!
}

class HomeView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//#MARK: Constants
    let cellRIdent = "BillCell"
    
//MARK: Variables
    var bills: [BillInformation]!
    var selectedBillIndex: Int!
    var CreatedDatabase: Bool = false
    
//MARK: Outlets
    @IBOutlet weak var billListTV: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
//MARK: Actions
    @IBAction func returnFromSettings(segue : UIStoryboardSegue)
    {
        bills = DBManager.shared.loadBills()
        self.billListTV.reloadData()
    }
    
    @IBAction func returnFromBillDetails(segue : UIStoryboardSegue)
    {
        bills = DBManager.shared.loadBills()
        self.billListTV.reloadData()
    }
    
    @IBAction func returnFromAddBill(segue : UIStoryboardSegue)
    {
        bills = DBManager.shared.loadBills()
        self.billListTV.reloadData()
        SetLabels()
    }
    
//MARK: Functions
    func SetLabels()
    {
        totalLabel.text = String(describing: DBManager.shared.loadBillsTotal().decimalValue)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (bills != nil) ? bills.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellRIdent, for: indexPath) as! BillsHomeTableViewCell
        
        
        let currentBill = bills[indexPath.row]
        
        cell.billNamesLabel?.text = currentBill.billName
        cell.dueDate?.text = currentBill.endDate
        
        if currentBill.uec == false
        {
            cell.uecLabel.text = "No"
        }
        else
        {
            cell.uecLabel.text = "Yes"
        }
        cell.costLabel?.text = "$" + String(describing: currentBill.cost.decimalValue)
        cell.paidLabel?.text = "$" + String(describing: currentBill.paid.decimalValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBillIndex = indexPath.row
        performSegue(withIdentifier: "idBillDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if DBManager.shared.deleteBill(withID: bills[indexPath.row].billID) {
                bills.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }

//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        billListTV.tableFooterView = UIView(frame: .zero)
        
        billListTV.delegate = self
        billListTV.dataSource = self
        
        if CreatedDatabase == false {
        CreatedDatabase = DBManager.shared.createDatabase()
        }
        
        SetLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "idBillDetails" {
                let nav = segue.destination as! UINavigationController
                let billDetailsViewController = nav.topViewController as! BillDetailsView
                
                selectedBillIndex = billListTV.indexPathForSelectedRow?.row

                billDetailsViewController.billID = bills[selectedBillIndex].billID
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bills = DBManager.shared.loadBills()
        billListTV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




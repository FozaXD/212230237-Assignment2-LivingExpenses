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

class HomeView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
//#MARK: Constants
    let cellRIdent = "BillCell"
    
//MARK: Variables
    var bills: [BillInformation]!
    
    var filteredBills:[BillInformation] = []
    var searchActive : Bool = false
    
    var selectedBillIndex: Int!
    var CreatedDatabase: Bool = false
    
//MARK: Outlets
    @IBOutlet weak var billListTV: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
//MARK: Actions
    
    @IBAction func unwindFromSettingsToHomeView(segue:UIStoryboardSegue)
    {
        bills = DBManager.shared.loadBills()
        self.billListTV.reloadData()
    }
    
    @IBAction func unwindFromBillDetailsToHomeView(segue:UIStoryboardSegue)
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
    
    func setFilteredBills ()
    {
        filteredBills = bills
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredBills.count
        }
        return (bills != nil) ? bills.count : 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellRIdent, for: indexPath) as! BillsHomeTableViewCell
        
        if(searchActive){
            let currentBill = filteredBills[indexPath.row]
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
            
        }
        else
        {
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
        }
        
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredBills = bills.filter({ (text) -> Bool in
            let tmp: BillInformation = text
            if tmp.billName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil
            {
                return true
            }
            else
            {
                return false
            }
            
        })
        if(filteredBills.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.billListTV.reloadData()
    }
    
//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        billListTV.tableFooterView = UIView(frame: .zero)
        
        billListTV.delegate = self
        billListTV.dataSource = self
        searchBar.delegate = self
        
        if CreatedDatabase == false {
        CreatedDatabase = DBManager.shared.createDatabase()
        }
        
        SetLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass billID object to the new view controller so we know what bill to get details for and display.
        //Also sets the return path to the correct view.
        if let identifier = segue.identifier {
            if identifier == "idBillDetails" {
                let nav = segue.destination as! UINavigationController
                let billDetailsViewController = nav.topViewController as! BillDetailsView
                
                selectedBillIndex = billListTV.indexPathForSelectedRow?.row

                if (searchActive)
                {
                    billDetailsViewController.billID = filteredBills[selectedBillIndex].billID
                }
                else
                {
                billDetailsViewController.billID = bills[selectedBillIndex].billID
                }
                billDetailsViewController.segueFromController = "HomeView"
            }
        }
        
        if let identifier = segue.identifier {
            if identifier == "settingsSegue" {
                let nav = segue.destination as! UINavigationController
                let chld = nav.topViewController as! SettingsView
                chld.segueFromController = "HomeView"
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

//MARK: Extenstions
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


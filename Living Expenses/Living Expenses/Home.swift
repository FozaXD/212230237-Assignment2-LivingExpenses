//
//  Home.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 29/4/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

//#MARK: Struct
//Sets the data holder so that tableviews can use it.
struct BillInformation {
    var billID: Int!
    var billName: String!
    var startDate: String!
    var endDate: String!
    var uec: Bool!
    var cost: NSNumber!
    var paid: NSNumber!
    var utilitytype: String!
    var costperunit: NSNumber!
    var dailycost: NSNumber!
}

struct BillPaymentInformation {
    var paymentID: Int!
    var billID: Int!
    var billName: String!
    var userID: Int!
    var user: String!
    var payment: NSNumber!
}

struct UtilityReadingsInformation {
    var billID: Int!
    var billName: String!
    var reading: Int!
}

struct UtilityTypesInformation {
    var utilityID: Int!
    var utilityName: String!
}

struct UserPayInformation {
    var userID: Int!
    var userName: String!
    var startDate: String!
    var endDate: String!
    var paidOn: String!
    var other: Bool!
    var amount: NSNumber!
}

struct Settings {
    var settingID: Int!
    var user1Name: String!
    var user2Name: String!
    var user1paid: Int!
    var user2paid: Int!
    var user1lastPayDate: String!
    var user2lastPayDate: String!
    var user1nextPayDate: String!
    var user2nextPayDate: String!
    var shareUser1: Int!
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
//Set (old) unwind actions.
    @IBAction func unwindFromSettingsToHomeView(segue:UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindFromBillDetailsToHomeView(segue:UIStoryboardSegue)
    {
    }
    
    @IBAction func returnFromAddBill(segue : UIStoryboardSegue)
    {
        SetLabels()
    }
    
//MARK: Functions
    func SetLabels()
    {
        totalLabel.text = String(describing: DBManager.shared.loadBillsTotal().decimalValue)
    }
    
    //Required for tableview (returns number of sections) - default is 1.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func setFilteredBills ()
    {
        filteredBills = bills
    }
    
    //Count number of rows used in tableview.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredBills.count
        }
        return (bills != nil) ? bills.count : 0;
    }
    
    //Set format and load bill details into each row (cell).
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        formatter.numberStyle = NumberFormatter.Style.currency
        
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
            print(currentBill.cost)
            cell.costLabel?.text = formatter.string(from: currentBill.cost)!
            cell.paidLabel?.text = formatter.string(from: currentBill.paid)!
            
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
            cell.costLabel?.text = formatter.string(from: currentBill.cost)!
            cell.paidLabel?.text = formatter.string(from: currentBill.paid)!
        }
        
        return cell
        
    }
    //Set selected bill details when row in tableview is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBillIndex = indexPath.row
        performSegue(withIdentifier: "idBillDetails", sender: nil)
    }
    
    //Allows the deletion of rows (and record from database).
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if DBManager.shared.deleteBill(withID: bills[indexPath.row].billID) {
                bills.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    //Set search bar states
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
    
    //Set search bar data.
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
        
        //On inital boot add a record in SettingsDB required to run. Could have put this inside the check if database created but wanted create futher understanding of database wrapper by generating new query.
        if DBManager.shared.loadSettingsRecordCount() == 0
        {
            DBManager.shared.insertSettingsData(user1Name: "User1", user2Name: "User2", user1Paid: 0, user2Paid: 0, user1LastPay: "01/01/17", user2LastPay: "01/01/17", user1NextPay: "01/01/17", user2NextPay: "01/01/17", user1Share: 50)
        }
        
        billListTV.tableFooterView = UIView(frame: .zero)
        
        billListTV.delegate = self
        billListTV.dataSource = self
        searchBar.delegate = self
        
        //Check if database is created.
        if CreatedDatabase == false {
        CreatedDatabase = DBManager.shared.createDatabase()
        }
        
        SetLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.text = ""
        self.title = "Home"
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

                if searchBar.text != ""
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
    }
    
}

//MARK: Extenstions
//Allows user to dismiss keyboard when entering information into text boxes.
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


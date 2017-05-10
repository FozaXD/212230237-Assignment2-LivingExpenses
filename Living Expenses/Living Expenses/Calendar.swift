//
//  ViewController.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 28/4/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarView: UIViewController, UITableViewDelegate, UITableViewDataSource  {
//MARK: Constants
    let formatter = DateFormatter()
    let cellRIdent = "BillCell"
    let selectedMonthColour = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    let thisMonthColour = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let otherMonthColour = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
//MARK: Variables
    var billsBySetDate: [BillInformation]!
    var bills: [BillInformation]!
    var selectedBillIndex: Int!
    var datesToBeSelected: [Date] = []
    var selectedListDate: Date = Date.distantPast
    
//MARK: Outlets
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dateSpecificTableView: UITableView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

//MARK: Action
    @IBAction func unwindFromSettingsToCalendarView(segue:UIStoryboardSegue)
    {
        //bills = DBManager.shared.loadBills()
        //self.billListTV.reloadData()
    }
    
    @IBAction func unwindFromBillDetailsToCalendarView(segue:UIStoryboardSegue)
    {
        //bills = DBManager.shared.loadBills()
        //self.billListTV.reloadData()
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
        return (billsBySetDate != nil) ? billsBySetDate.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellRIdent, for: indexPath) as! BillsHomeTableViewCell
        
        
        let currentBill = billsBySetDate[indexPath.row]
        
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
            if DBManager.shared.deleteBill(withID: billsBySetDate[indexPath.row].billID) {
                billsBySetDate.remove(at: indexPath.row)
                tableView.reloadData()
                reloadData()
            }
        }
    }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(visibleDates: visibleDates)
        }
        
    }
    
    func setupViewsOfCalendar(visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    func selectCalendarCell(view: JTAppleCell, cellState: CellState)
    {
        guard let validCell = view as? CustomCell else { return }
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        }
        else
        {
            validCell.selectedView.isHidden = true
        }
    }

    func configureCalCellTextColour(view: JTAppleCell?, cellState: CellState)
    {
        guard let validCell = view as? CustomCell else {return}
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColour
            
        }
        else
        {
            if cellState.dateBelongsTo == .thisMonth
            {
                validCell.dateLabel.textColor = thisMonthColour
            }
            else
            {
                validCell.dateLabel.textColor = otherMonthColour
            }
        }
    }
    
    func setBillDates() {
        datesToBeSelected = []
        dateFormatter.dateFormat = "dd/MM/yy"
        
        for idB in bills
        {
           datesToBeSelected.append(dateFormatter.date(from: idB.endDate)!)
        }
    }
    
    func reloadData() {
        billsBySetDate = DBManager.shared.loadBillsForDate(date: selectedListDate)
        bills = DBManager.shared.loadBills()
        dateSpecificTableView.reloadData()
        calendarView.reloadData()
    }
    
//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        dateSpecificTableView.tableFooterView = UIView(frame: .zero)
        
        dateSpecificTableView.delegate = self
        dateSpecificTableView.dataSource = self
        
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        setBillDates()
        setupCalendarView()
        setBillDates()
        SetLabels()
    }

    // Get the new view controller using segue.destinationViewController.
    // Pass billID object to the new view controller so we know what bill to get details for and display.
    //Also sets the return path to the correct view.
    //Similar to homeview-prepare.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "idBillDetails" {
                let nav = segue.destination as! UINavigationController
                let billDetailsViewController = nav.topViewController as! BillDetailsView
                
                selectedBillIndex = dateSpecificTableView.indexPathForSelectedRow?.row
                
                billDetailsViewController.billID = billsBySetDate[selectedBillIndex].billID
                
                billDetailsViewController.segueFromController = "CalendarView"
            }
        }
        
        if let identifier = segue.identifier {
            if identifier == "settingsSegue" {
                let nav = segue.destination as! UINavigationController
                let chld = nav.topViewController as! SettingsView
                chld.segueFromController = "CalendarView"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: Extenstions
extension CalendarView: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 12 31")!
        
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        selectCalendarCell(view: cell, cellState: cellState)
        configureCalCellTextColour(view: cell, cellState: cellState)
        
        setBillDates()
        
        for d in datesToBeSelected
        {
            if date == d {
                cell.selectedRangeDatesView.isHidden = false
                break
            } else {
                cell.selectedRangeDatesView.isHidden = true
            }
        }

        return cell
    }
    
       
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if cell == nil {return}
        selectCalendarCell(view: cell!, cellState: cellState)
        configureCalCellTextColour(view: cell, cellState: cellState)
        selectedListDate = date
        reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if cell == nil {return}
        selectCalendarCell(view: cell!, cellState: cellState)
        configureCalCellTextColour(view: cell, cellState: cellState)
        selectedListDate = Date.distantPast
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(visibleDates: visibleDates)
    }
}

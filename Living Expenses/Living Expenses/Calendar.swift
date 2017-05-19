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
    let formatterDate = DateFormatter()
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
    }
    
    @IBAction func unwindFromBillDetailsToCalendarView(segue:UIStoryboardSegue)
    {
    }
    
//MARK: Functions
    //General initalization.
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
    
    //Sets each rows data in the table view. Dataset (grabbed via query in wrapper) only collects records associated with selected calendar date.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        formatter.numberStyle = NumberFormatter.Style.currency
        
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
        cell.costLabel?.text = formatter.string(from: currentBill.cost)!
        cell.paidLabel?.text = formatter.string(from: currentBill.paid)!
        
        return cell
    }

    //Parse selected bill information to bill details.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBillIndex = indexPath.row
        performSegue(withIdentifier: "idBillDetails", sender: nil)
    }
    
    //Delete record.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if DBManager.shared.deleteBill(withID: billsBySetDate[indexPath.row].billID) {
                billsBySetDate.remove(at: indexPath.row)
                tableView.reloadData()
                reloadData()
            }
        }
    }
    
    //Setups required for JTAppleCalendar
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(visibleDates: visibleDates)
        }
        
    }
    
    //Formate Month and Year label used on calendar screen (i.e. changes based with calendar).
    func setupViewsOfCalendar(visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatterDate.dateFormat = "yyyy"
        yearLabel.text = formatterDate.string(from: date)
        
        formatterDate.dateFormat = "MMMM"
        monthLabel.text = formatterDate.string(from: date)
    }
    
    //Allows selection of datas inside JTAppleCalendar.
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

    //Configures JTAppleCalendar.
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
    
    //Gets the bill dates used to highlight due dates in the JTAppleCalendar.
    func setBillDates() {
        if bills == nil {return}
        datesToBeSelected = []
        dateFormatter.dateFormat = "dd/MM/yy"
        
        for idB in bills
        {
           datesToBeSelected.append(dateFormatter.date(from: idB.endDate)!)
        }
    }
    
    //Refresh function.
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
        self.title = "Calendar"
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
//JTAppleCalendar required extenstions. (initializes the parameters required by JTAppleCalendar).
extension CalendarView: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatterDate.dateFormat = "yyyy MM dd"
        formatterDate.timeZone = Calendar.current.timeZone
        formatterDate.locale = Calendar.current.locale
        
        let startDate = formatterDate.date(from: "2017 01 01")!
        let endDate = formatterDate.date(from: "2030 12 31")!
        
        
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

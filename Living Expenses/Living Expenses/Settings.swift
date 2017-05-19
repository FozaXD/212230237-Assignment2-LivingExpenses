//
//  Settings.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 3/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//
//Youtube video explanation: https://youtu.be/aH1imREjyV4
//Github: https://github.com/FozaXD/212230237-Assignment2-LivingExpenses

import UIKit

class SettingsView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
//MARK: Constants
    let dateFormatter = DateFormatter()
    let paidPicker = ["Weekly", "Fortnightly", "Monthly", "Quarterly"];
    
//MARK: Variables
    var segueFromController : String!
    var user1NextPay: String!
    var user2NextPay: String!
    
    var settings: Settings!
    var settingsID: Int!
    
    var activeField: UITextField?
    
//MARK: Outlets
    @IBOutlet weak var user1Name: UITextField!
    @IBOutlet weak var user2Name: UITextField!
    @IBOutlet weak var user1ShareTxtBox: UITextField!
    @IBOutlet weak var user1ShareStepper: UIStepper!
    @IBOutlet weak var user2ShareTxtBox: UITextField!
    @IBOutlet weak var user2ShareStepper: UIStepper!
    @IBOutlet weak var user1PaidPicker: UIPickerView!
    @IBOutlet weak var user2PaidPicker: UIPickerView!
    @IBOutlet weak var user1DatePicker: UIDatePicker!
    @IBOutlet weak var user2DatePicker: UIDatePicker!
    @IBOutlet weak var user1NextPayLabel: UILabel!
    @IBOutlet weak var user2NextPayLable: UILabel!
    
//MARK: Actions
    //Set the stepper values based on each other.
    @IBAction func user1StepperValueChange(_ sender: UIStepper) {
        user1ShareTxtBox.text = Int(sender.value).description
        user2ShareStepper.value = 100 - sender.value
        user2ShareTxtBox.text = String(user2ShareStepper.value)
    }
    
    @IBAction func user2StepperValueChange(_ sender: UIStepper) {
        user2ShareTxtBox.text = Int(sender.value).description
        user1ShareStepper.value = 100 - sender.value
        user1ShareTxtBox.text = String(user1ShareStepper.value)
    }
    
    @IBAction func useIntellegentMode(_ sender: UISwitch) {
        enableStateInput(state: sender.isOn)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        unwindSegue()
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        SaveSettings()
        unwindSegue()
    }
    
    @IBAction func user1DatePickerChange(_ sender: UIDatePicker) {
        CalcNextPayDates()
        SetNextPayLabel()
    }
    
    @IBAction func user2DatePickerChange(_ sender: UIDatePicker) {
        CalcNextPayDates()
        SetNextPayLabel()
    }
    
//MARK: Functions
    //Update the settings record for SettingsID 1, done via the database wrapper.
    func SaveSettings() {
        dateFormatter.dateFormat = "dd/MM/yy"
        DBManager.shared.updateSettings(withID: 1, user1Name: user1Name.text!, user2Name: user2Name.text!, user1Paid: user1PaidPicker.selectedRow(inComponent: 0), user2Paid: user2PaidPicker.selectedRow(inComponent: 0), user1LastPay: dateFormatter.string(from: user1DatePicker.date), user2LastPay: dateFormatter.string(from: user2DatePicker.date), user1NextPay: user1NextPayLabel.text!, user2NextPay: user2NextPayLable.text!, user1Share: Int(user1ShareStepper.value))
    }
    
    //Calculate the pay difference dates between last paid and next pay (i.e. using the pay cycle variable).
    func CalcNextPayDates() {
        dateFormatter.dateFormat = "dd/MM/yy"
        
        switch user1PaidPicker.selectedRow(inComponent: 0) {
        case 0:
            user1NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.day, value: 7, to: user1DatePicker.date))
        case 1:
            user1NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.day, value: 14, to: user1DatePicker.date))
        case 2:
            user1NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.month, value: 1, to: user1DatePicker.date))
        case 3:
            user1NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.month, value: 3, to: user1DatePicker.date))
        default:
            user1NextPay = dateFormatter.string(for: user1DatePicker.date)
        }
        
        switch user2PaidPicker.selectedRow(inComponent: 0) {
        case 0:
            user2NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.day, value: 7, to: user2DatePicker.date))
        case 1:
            user2NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.day, value: 14, to: user2DatePicker.date))
        case 2:
            user2NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.month, value: 1, to: user2DatePicker.date))
        case 3:
            user2NextPay = dateFormatter.string(for: NSCalendar.current.date(byAdding: Calendar.Component.month, value: 3, to: user2DatePicker.date))
        default:
            user2NextPay = dateFormatter.string(for: user2DatePicker.date)
        }

    }

    //Enables user to return to the correct view.
    func unwindSegue() {
        if segueFromController == "HomeView"
        {
            self.performSegue(withIdentifier: "returnFromSettingsToHomeSegueId", sender: nil)
        }
        else if segueFromController == "CalendarView"
        {
            self.performSegue(withIdentifier: "returnFromSettingsToCalendarSegueId", sender: nil)
            
        }
    }
    
    //General data initialization.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return paidPicker.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return paidPicker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        CalcNextPayDates()
        SetNextPayLabel()
    }
    
    func SetLabels() {
        dateFormatter.dateFormat = "dd/MM/yy"
        
        user1Name.text = settings.user1Name
        user2Name.text = settings.user2Name
        user1ShareStepper.value = Double(settings.shareUser1)
        user2ShareStepper.value = Double(100 - settings.shareUser1)
        user1ShareTxtBox.text = String(user1ShareStepper.value)
        user2ShareTxtBox.text = String(user2ShareStepper.value)
        user1DatePicker.date = dateFormatter.date(from: settings.user1lastPayDate)!
        user2DatePicker.date = dateFormatter.date(from: settings.user2lastPayDate)!
        user1NextPayLabel.text = settings.user1nextPayDate
        user2NextPayLable.text = settings.user2nextPayDate
        
        setSelectedPaidPickers()
    }
    
    func setSelectedPaidPickers()
    {
        switch settings.user1paid {
        case 0:
            user1PaidPicker.selectRow(0, inComponent: 0, animated: true)
        case 1:
            user1PaidPicker.selectRow(1, inComponent: 0, animated: true)
        case 2:
            user1PaidPicker.selectRow(2, inComponent: 0, animated: true)
        case 3:
            user1PaidPicker.selectRow(3, inComponent: 0, animated: true)
        default:
            user1PaidPicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        switch settings.user2paid {
        case 0:
            user2PaidPicker.selectRow(0, inComponent: 0, animated: true)
        case 1:
            user2PaidPicker.selectRow(1, inComponent: 0, animated: true)
        case 2:
            user2PaidPicker.selectRow(2, inComponent: 0, animated: true)
        case 3:
            user2PaidPicker.selectRow(3, inComponent: 0, animated: true)
        default:
            user2PaidPicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func SetNextPayLabel() {
        user1NextPayLabel.text = user1NextPay
        user2NextPayLable.text = user2NextPay
    }
    
    //Allows textboxes below the keyboard to be pushed up so that the user can see.
    func keyboardWillShow(notification: NSNotification) {
        if (activeField == user1Name) {return}
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (activeField == user1Name) {return}
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
        self.view.frame.origin.y = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }

//MARK: Functions
    func enableStateInput(state: Bool)
    {
        user1ShareTxtBox.isEnabled = state
        user1ShareStepper.isEnabled = state
        user2ShareTxtBox.isEnabled = state
        user2ShareStepper.isEnabled = state
        
    }
  
//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.user1PaidPicker.dataSource = self;
        self.user1PaidPicker.delegate = self;
        self.user2PaidPicker.dataSource = self;
        self.user2PaidPicker.delegate = self;
        self.user1Name.delegate = self
        self.user2Name.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tabBar.isHidden = true;
        settingsID = 1
        
        if let id = settingsID {
            DBManager.shared.loadSettings(withID: id, completionHandler: { (setting) in
                DispatchQueue.main.async {
                    if setting != nil {
                        self.settings = setting
                        self.SetLabels()
                    }
                }
            })
        }
        CalcNextPayDates()
        SetNextPayLabel()
        self.title = "Bill Details"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

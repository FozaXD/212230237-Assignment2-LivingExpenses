//
//  AddBill.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 4/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit
let dateFormatter = DateFormatter()

class AddBillView: UIViewController,  UITextFieldDelegate {
//MARK: Constants
    let formatter = NumberFormatter()
    
//MARK: Variables
    var isUEC: Bool = false
    var activeField: UITextField?
    
//MARK: Outlets
    @IBOutlet weak var billText: UITextField!
    @IBOutlet weak var costText: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var utilitySettingsView: UIView!
    @IBOutlet weak var costPerUnit: UITextField!
    @IBOutlet weak var dailyCharge: UITextField!
    @IBOutlet weak var isUECOutlet: UISwitch!
    
//MARK: Actions
    @IBAction func editingBegan(sender: UITextField) {
        activeField = sender
    }
    
    @IBAction func toggleUEC(_ sender: UISwitch) {
        utilitySettingsView.isHidden = !sender.isOn
        costText.isEnabled = !sender.isOn
    }
    @IBAction func addBill(_ sender: UIButton) {
        formatter.generatesDecimalNumbers = true
        dateFormatter.dateFormat = "dd/MM/yy"
        isUEC = isUECOutlet.isOn
        
        var costTextString: String
        costTextString = costText.text!
        if !(costTextString.contains("."))
        {
             self.costText.text = self.costText.text! + ".00"
        }
        
        if (costText.text != nil || billText.text != nil)
        {
            DBManager.shared.insertBillData(billName: billText.text!, startDate: String(describing: dateFormatter.string(from: startDatePicker.date)), endDate: String(describing: dateFormatter.string(from: endDatePicker.date)), uec: isUEC, cost: DBManager.shared.decimal(string: costText.text!), utilityType: "Test", costPerUnit: DBManager.shared.decimal(string: costPerUnit.text!), dailyCost: DBManager.shared.decimal(string: dailyCharge.text!))
        
            dismissViewController()
        }
    }

//MARK: Functions
    func dismissViewController() {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if activeText !=
//        if string.characters.count == 0 {
//            return true
//        }
//        
//        let currentText = costText.text ?? ""
//        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
//        
//        return prospectiveText.isNumeric() &&
//            prospectiveText.characters.count <= 7
//    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (activeField == costText || activeField == billText) {return}
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (activeField == costText || activeField == billText) {return}
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Pretty pointless as set keyboards to be decimal type, which have no "next" or "done", left code in case of future use. 
        if activeField == billText
        {
            costText.becomeFirstResponder()
        }
        else if (activeField == costText && isUEC == false)
        {
            costPerUnit.becomeFirstResponder()
        }
        else if (activeField == costPerUnit && isUEC == true)
        {
            dailyCharge.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        return true
    }

//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
    
        costText.delegate = self
        costText.keyboardType = .decimalPad
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "New Bill"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: Extenstions
extension String {
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        scanner.locale = Locale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
}

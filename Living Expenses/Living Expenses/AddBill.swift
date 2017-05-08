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
    
//MARK: Outlets
    @IBOutlet weak var billText: UITextField!
    @IBOutlet weak var costText: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!

//MARK: Actions
    @IBAction func addBill(_ sender: UIButton) {
        formatter.generatesDecimalNumbers = true
        dateFormatter.dateFormat = "dd/MM/yy"
        
        var costTextString: String
        costTextString = costText.text!
        if !(costTextString.contains("."))
        {
             self.costText.text = self.costText.text! + ".00"
        }
        
        if (costText.text != nil || billText.text != nil)
        {
            DBManager.shared.insertBillData(billName: billText.text!, startDate: String(describing: dateFormatter.string(from: startDatePicker.date)), endDate: String(describing: dateFormatter.string(from: endDatePicker.date)), uec: false, cost: DBManager.shared.decimal(string: costText.text!))
        
            dismissViewController()
        }
    }

//MARK: Functions
    func dismissViewController() {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        
        let currentText = costText.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return prospectiveText.isNumeric() &&
            prospectiveText.characters.count <= 7
    }

//MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
    
        costText.delegate = self
        costText.keyboardType = .numbersAndPunctuation
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

extension String {
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        scanner.locale = Locale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
}

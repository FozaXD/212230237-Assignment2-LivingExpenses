//
//  BillsHomeTableViewCell.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 5/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

//Used to enable multiple textboxes per cell on the tableview, which creates the ability to use columns.
class BillsHomeTableViewCell: UITableViewCell {
//MASK: Outlets
//Connects labels to become avaliable inside each tableview row, this allows us to give a column like appearance with the benefits given from TableViews.
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var billNamesLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var uecLabel: UILabel!
}

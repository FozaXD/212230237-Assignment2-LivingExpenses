//
//  CustomCell.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 29/4/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {
//MASK: Outlets
    //Creates the cell details and enables the use of JTAppleCalendar.
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedRangeDatesView: UIView!
}

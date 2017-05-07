//
//  Settings.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 3/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

class SettingsView: UIViewController{
//MARK: Outlets
    @IBOutlet weak var user1ShareTxtBox: UITextField!
    @IBOutlet weak var user1ShareStepper: UIStepper!
    @IBOutlet weak var user2ShareTxtBox: UITextField!
    @IBOutlet weak var user2ShareStepper: UIStepper!
    
//MARK: Actions
    @IBAction func useIntellegentMode(_ sender: UISwitch) {
        enableStateInput(state: sender.isOn)
    }

//MARK: Functions
    func dismissViewController() {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tabBar.isHidden = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.tabBar.isHidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

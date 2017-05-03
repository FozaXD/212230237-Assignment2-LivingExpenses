//
//  Settings.swift
//  Living Expenses
//
//  Created by Alexander Fotheringham on 3/5/17.
//  Copyright © 2017 Alexander Fotheringham. All rights reserved.
//

import UIKit

class SettingsView: UIViewController{

    
    @IBOutlet weak var user1ShareTxtBox: UITextField!

    @IBOutlet weak var user1ShareStepper: UIStepper!
    
    @IBOutlet weak var user2ShareTxtBox: UITextField!
    
    @IBOutlet weak var user2ShareStepper: UIStepper!
    
    @IBAction func useIntellegentMode(_ sender: UISwitch) {
        enableStateInput(state: sender.isOn)
    }
    
    func enableStateInput(state: Bool)
    {
        user1ShareTxtBox.isEnabled = state
        user1ShareStepper.isEnabled = state
        user2ShareTxtBox.isEnabled = state
        user2ShareStepper.isEnabled = state
        
    }
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

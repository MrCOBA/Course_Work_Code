//
//  firstWelcomeScreenController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 13.05.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class firstWelcomeScreenComtroller: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
    }
    
    @IBAction func okBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "turnOnSmartMode", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "turnOnSmartMode"{
            let destination = segue.destination as? ViewController
            destination?.isSMART = true
        }
    }
}

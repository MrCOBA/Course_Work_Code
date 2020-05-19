//
//  menuViewController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 14.05.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class menuViewController:UIViewController{
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var ID:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        backButton.layer.cornerRadius = 12
        selectButton.layer.cornerRadius = 12
        createButton.layer.cornerRadius = 12
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createModel"{
            let destination = segue.destination as? createViewController
            destination?.ID = ID
        } else if segue.identifier == "backToChat"{
            let destination = segue.destination as? ViewController
            destination?.ID = ID
        } else if segue.identifier == "selectModel"{
            let destination = segue.destination as? EditScreenController
            destination?.ID = ID
        }
    }
    
    @IBAction func backSwipe(_ sender: Any) {
        performSegue(withIdentifier: "backToChat", sender: nil)
    }
    
    @IBAction func selectBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectModel", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToChat", sender: nil)
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "createModel", sender: nil)
    }
    
}

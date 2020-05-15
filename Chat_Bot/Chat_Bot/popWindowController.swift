//
//  popWindowController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 28.04.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class popWindowController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var editHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var editModelWindow: UIView!
    @IBOutlet weak var newContextField: UITextField!
    @IBOutlet weak var newTextResponseField: UITextField!
    @IBOutlet weak var appearButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    let alert = UIAlertController(title: "Error", message: "Fill all gaps!", preferredStyle: .alert)
    
    var PATH:String = "https://nltkbot.pythonanywhere.com/edit/"
    var ID:Int = 0
    var model:String = ""
    var FLAG:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        let gestureView = UITapGestureRecognizer(target: self, action: #selector (self.viewTapped(_:)))
        self.view.addGestureRecognizer(gestureView)
        
        newContextField.delegate = self
        newTextResponseField.delegate = self
        cancelButton.layer.cornerRadius = 12
        appearButton.layer.cornerRadius = 12
        addButton.layer.cornerRadius = 12
        modelLabel.text = "Model: \(model)"
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")
              @unknown default:
                    print("unknown default")
            }}))
        editModelWindow.layer.cornerRadius = 12
        editModelWindow.layer.masksToBounds = true
    }
    @IBAction func quitWithCanseling(_ sender: Any) {
        if FLAG{
            performSegue(withIdentifier: "finishEditing1", sender: nil)
        }
        else{
            performSegue(withIdentifier: "finishEditing2", sender: nil)
        }
    }
    
    @IBAction func addNewContext(_ sender: Any) {
        if !newContextField.text!.isEmpty && !newTextResponseField.text!.isEmpty{
            let newCntxt = (newContextField.text!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
            let newRspns = (newTextResponseField.text!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
            let request = PATH + "\(ID)/\(newCntxt)/\(newRspns)"
            getJSON(httpRequest: request)
        }
        else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func appearChanges(_ sender: Any) {
        self.performSegue(withIdentifier: "appearChanges", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishEditing1"{
            let destination = segue.destination as? EditScreenController
            destination!.ID = ID
        }
        else if segue.identifier == "appearChanges"{
            let destination = segue.destination as? ViewController
            destination!.ID = ID
        }
    }
    
    func getJSON(httpRequest: String){
        let http: HTTPManager = HTTPManager();
        
        let url: URL = URL(string: httpRequest)!;
        
        http.retrieveURL(url){
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else {return}
            print("JSON: ", json);
            self!.newContextField.text! = ""
            self!.newTextResponseField.text! = ""
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded();
        UIView.animate(withDuration: 0.5, animations: {
            self.editHeightConstraint.constant = 275;
            self.view.layoutIfNeeded();
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded();
        UIView.animate(withDuration: 0.5, animations: {
            self.editHeightConstraint.constant = 195;
            self.view.layoutIfNeeded();
        }, completion: nil)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer? = nil){
        newContextField.resignFirstResponder();
        newTextResponseField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newContextField.resignFirstResponder();
        newTextResponseField.resignFirstResponder();
        return true;
    }
}

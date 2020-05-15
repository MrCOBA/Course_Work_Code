//
//  createViewController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 14.05.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class createViewController:UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var PATH: String = "https://nltkbot.pythonanywhere.com/create"
    var id2dataset: [String] = []
    var ID: Int = 0
    let alert = UIAlertController(title: "Error", message: "Fill model name gap!", preferredStyle: .alert)
    
    var newID:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        nameField.delegate = self
        createButton.layer.cornerRadius = 12
        backButton.layer.cornerRadius = 12
        saveButton.layer.cornerRadius = 12
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
          switch action.style{
          case .default:
                if self.alert.title == "Successful"{
                    self.performSegue(withIdentifier: "editModel", sender: nil)
                }
          case .cancel:
                if self.alert.title == "Successful"{
                    self.performSegue(withIdentifier: "editModel", sender: nil)
                }
          case .destructive:
                if self.alert.title == "Successful"{
                    self.performSegue(withIdentifier: "editModel", sender: nil)
                }
          @unknown default:
                if self.alert.title == "Successful"{
                    self.performSegue(withIdentifier: "editModel", sender: nil)
                }
        }}))
    }
    
    @IBAction func saveSwipe(_ sender: Any) {
        performSegue(withIdentifier: "saveModel", sender: nil)
    }
    
    @IBAction func backSwipe(_ sender: Any) {
        performSegue(withIdentifier: "backToModel", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToModel", sender: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "saveModel", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editModel"{
            let destination = segue.destination as? popWindowController
            destination?.ID = newID
            destination?.FLAG = false
            destination?.model = nameField.text! + ".xlsx"
        }
        else if segue.identifier == "saveModel"{
            let destination = segue.destination as? ViewController
            destination?.ID = newID
        }
        else if segue.identifier == "backToModel"{
            let destination = segue.destination as? menuViewController
            destination?.ID = ID
        }
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        if !nameField.text!.isEmpty{
            let request:String = "https://nltkbot.pythonanywhere.com/update"
            getJSON(httpRequest: request);
            var flag:Bool = true
            for dataset in id2dataset{
                let index = dataset.firstIndex(of: ".") ?? dataset.endIndex
                let ind_name = dataset[..<index]
                let name = String(ind_name)
                if name == nameField.text!{
                    alert.title = "Error"
                    alert.message = "This name already exists!"
                    self.present(alert, animated: true, completion: nil)
                    flag = false
                    break
                }
            }
            if flag && checkName(name: nameField.text!){
                let request:String = "https://nltkbot.pythonanywhere.com/create/\(nameField.text!).xlsx"
                addModelJSON(httpRequest: request)
            }
        }
        else{
            alert.title = "Error"
            alert.message = "Fill model name gap!"
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkName(name: String) -> Bool{
        var flag:Bool = true
        for char in name{
            if char >= "a" &&  char <= "z" || char >= "A" &&  char <= "Z"{
                continue
            }
            else if char >= "0" &&  char <= "9"{
                continue
            }
            else if char == "_" || char == "@"{
                continue
            }
            else{
                flag = false
                break
            }
        }
        if !flag{
            alert.title = "Error"
            alert.message = "Name have wrong symbols!"
            self.present(alert, animated: true, completion: nil)
        }
        return flag
    }
    
    func getJSON(httpRequest: String){
        let http: HTTPManager = HTTPManager();
        
        let url: URL = URL(string: httpRequest)!;
        
        http.retrieveURL(url){
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else {return}
            print("JSON: ", json);
            
            do{
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: []);
                guard
                    let jsonObject = jsonObjectAny as? [String: String] else{
                            return;
                    }
                self!.id2dataset = []
                for i in 0...jsonObject.count - 1{
                    self!.id2dataset.insert(jsonObject[String(i)]!, at: i)
                }
            }catch{
                print("Can't serialize data.");
            }
        }
    }
    
    func addModelJSON(httpRequest: String){
        let http: HTTPManager = HTTPManager();
        
        let url: URL = URL(string: httpRequest)!;
        
        http.retrieveURL(url){
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else {return}
            print("JSON: ", json);
            do{
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: []);
                guard
                    let jsonObject = jsonObjectAny as? [String: Any?],
                    let id = jsonObject ["id"] as? Int else{
                            return;
                    }
                self!.newID = id
            }catch{
                print("Can't serialize data.");
            }
            self!.alert.title = "Successful"
            self!.alert.message = "New model was created!"
            self!.present(self!.alert, animated: true, completion: nil)
        }
    }
}

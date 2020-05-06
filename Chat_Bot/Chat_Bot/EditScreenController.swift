//
//  EditScreenController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 27.04.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import UIKit


class EditScreenController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var newModelField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var newModelButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var modelPicker: UIPickerView!
    
    var PATH: String = "https://nltkbot.pythonanywhere.com/create"
    var id2dataset: [String] = []
    var ID: Int = 0
    
    let alert = UIAlertController(title: "Error", message: "Fill model name gap!", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        let gestureView = UITapGestureRecognizer(target: self, action: #selector (self.viewTapped(_:)))
        self.view.addGestureRecognizer(gestureView)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
          switch action.style{
          case .default:
                if self.alert.title == "Successful"{
                    self.ID = self.id2dataset.count
                    let request:String = "https://nltkbot.pythonanywhere.com/update"
                    self.getJSON(httpRequest: request);
                }
          case .cancel:
                if self.alert.title == "Successful"{
                    self.ID = self.id2dataset.count
                    let request:String = "https://nltkbot.pythonanywhere.com/update"
                    self.getJSON(httpRequest: request);
                }
          case .destructive:
                if self.alert.title == "Successful"{
                    self.ID = self.id2dataset.count
                    let request:String = "https://nltkbot.pythonanywhere.com/update"
                    self.getJSON(httpRequest: request);
                }
          @unknown default:
                if self.alert.title == "Successful"{
                    self.ID = self.id2dataset.count
                    let request:String = "https://nltkbot.pythonanywhere.com/update"
                    self.getJSON(httpRequest: request);
                }
        }}))
        modelPicker.delegate = self
        modelPicker.dataSource = self
        newModelButton.layer.cornerRadius = 12
        backButton.layer.cornerRadius = 12
        editButton.layer.cornerRadius = 12
        saveButton.layer.cornerRadius = 12
        let request:String = "https://nltkbot.pythonanywhere.com/update"
        getJSON(httpRequest: request);
    }
    @IBAction func returnBack(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: nil)
    }
    
    @IBAction func createNewModel(_ sender: Any) {
        if !newModelField.text!.isEmpty{
            let request:String = "https://nltkbot.pythonanywhere.com/update"
            getJSON(httpRequest: request);
            var flag:Bool = true
            for dataset in id2dataset{
                let index = dataset.firstIndex(of: ".") ?? dataset.endIndex
                let ind_name = dataset[..<index]
                let name = String(ind_name)
                if name == newModelField.text!{
                    alert.title = "Error"
                    alert.message = "This name already exists!"
                    self.present(alert, animated: true, completion: nil)
                    flag = false
                    break
                }
            }
            if flag && checkName(name: newModelField.text!){
                let request:String = "https://nltkbot.pythonanywhere.com/create/\(newModelField.text!).xlsx"
                addModelJSON(httpRequest: request)
            }
        }
        else{
            alert.title = "Error"
            alert.message = "Fill model name gap!"
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editModel(_ sender: Any) {
        performSegue(withIdentifier: "startEditing", sender: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        performSegue(withIdentifier: "goToChat", sender: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return id2dataset.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return id2dataset[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startEditing"{
            let destination = segue.destination as? popWindowController
            destination!.ID = modelPicker.selectedRow(inComponent: 0)
            destination!.model = id2dataset[modelPicker.selectedRow(inComponent: 0)]
        }
        else if segue.identifier == "goToChat"{
            let destination = segue.destination as? ViewController
            destination!.ID = modelPicker.selectedRow(inComponent: 0)
        }
        else if segue.identifier == "back"{
            let destination = segue.destination as? ViewController
            destination!.ID = ID
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
                self!.modelPicker.reloadComponent(0)
                self!.modelPicker.selectRow(self!.ID, inComponent: 0, animated:true)
                self!.newModelField.resignFirstResponder();
                self!.newModelField.text! = ""
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
            self!.alert.title = "Successful"
            self!.alert.message = "New model was created!"
            self!.present(self!.alert, animated: true, completion: nil)
        }
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer? = nil){
        newModelField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newModelField.resignFirstResponder();
        return true;
    }
}

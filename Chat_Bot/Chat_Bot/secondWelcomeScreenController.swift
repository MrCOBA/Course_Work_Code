//
//  File.swift
//  Chat_Bot
//
//  Created by OparinOleg on 13.05.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class secondWelcomeScreenController:UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    var id2dataset: [String] = []
    @IBOutlet weak var modelPickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        modelPickerView.dataSource = self
        modelPickerView.delegate = self
        let request:String = "https://nltkbot.pythonanywhere.com/update"
        getJSON(httpRequest: request);
    }

    @IBAction func okBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "startChat", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startChat"{
            let destination = segue.destination as? ViewController
            destination!.ID = modelPickerView.selectedRow(inComponent: 0)
            destination!.isSMART = false
        }
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
                self!.modelPickerView.reloadComponent(0)
            }catch{
                print("Can't serialize data.");
            }
        }
    }
}

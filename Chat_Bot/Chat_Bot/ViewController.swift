//
//  ViewController.swift
//  Chat_Bot
//
//  Created by OparinOleg on 02.01.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import UIKit

struct ChatMessage{
    let text: String
    let isIncoming: Bool
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    fileprivate let cellId = "messageCell"
    var ID: Int = 0
    var PATH: String = ""
    var isSMART: Bool = false
    
    var messagesArray:[ChatMessage] = [ChatMessage]();
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        navigationItem.title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if isSMART{
            PATH = "https://nltkbot.pythonanywhere.com/getNLPanswer/"
        }
        else{
            PATH = "https://nltkbot.pythonanywhere.com/getanswer/"
        }
        
        sendButton.layer.cornerRadius = 12
        editButton.layer.cornerRadius = 12
        messageTableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        messageTableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        messageTableView.separatorStyle = .none
        // Do any additional setup after loading the view.
        self.messageTableView.delegate = self;
        self.messageTableView.dataSource = self;
        self.messageTextField.delegate = self;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.tableViewTapped(_:)));
        self.messageTableView.addGestureRecognizer(tapGesture);
        if isSMART{
            self.messagesArray.append(ChatMessage(text: "Hello, I am RNN based smart bot!", isIncoming: true));
            messageTableView.reloadData();
            scrollToBottom();
        }
        else{
            let request = "https://nltkbot.pythonanywhere.com/get/\(ID)"
            getFirstJSON(httpRequest: request)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func editModel(_ sender: Any) {
        performSegue(withIdentifier: "startEditing", sender: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        var Message:String = "";
        if(messageTextField.text != nil && messageTextField.text != ""){
            Message = messageTextField.text!;
            self.messagesArray.append(ChatMessage(text: Message, isIncoming: false))
            self.messageTableView.reloadData();
            self.scrollToBottom();
        }
        else{
            return;
        }
        Message = Message.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        //Message = Message.replacingOccurrences(of: " ", with: "%20")
        self.messageTextField.endEditing(true);
        let request:String = PATH + Message + (isSMART ? "" : "/" + String(ID))
        getJSON(httpRequest: request);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startEditing"{
            let destination = segue.destination as? menuViewController
            destination!.ID = ID
        }
    }
    
    //some methods for textBox
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded();
        UIView.animate(withDuration: 0.5, animations: {
            self.dockViewHeightConstraint.constant = 315
            self.messageTableViewHeightConstraint.constant = 0
            self.scrollToBottom();
            self.view.layoutIfNeeded();
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded();
        UIView.animate(withDuration: 0.5, animations: {
            self.dockViewHeightConstraint.constant = 60
            self.messageTableViewHeightConstraint.constant = 0
            self.scrollToBottom();
            self.view.layoutIfNeeded();
        }, completion: nil)
        if(messageTextField.text != nil && messageTextField.text != ""){
            messageTextField.text = "";
        }
    }
    
    //Some methods for tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
            cell.messageLabel.text = messagesArray[indexPath.row].text;
            
            cell.isIncoming = messagesArray[indexPath.row].isIncoming;
            return cell;
        }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.messageTableView.numberOfRows(inSection: (self.messageTableView.numberOfSections - 1)) - 1,
            section: self.messageTableView.numberOfSections - 1)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    @objc func tableViewTapped(_ sender: UITapGestureRecognizer? = nil){
        self.messageTextField.endEditing(true);
    }
    
    
    //Server connection
    
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
                    let jsonObject = jsonObjectAny as? [String: Any],
                    let answer = jsonObject["answer"] as? String else{
                        return;
                }
                self!.messagesArray.append(ChatMessage(text: answer, isIncoming: true))
                self!.messageTableView.reloadData();
                self!.scrollToBottom();
            }catch{
                print("Can't serialize data.");
            }
        }
    }
    
    func getFirstJSON(httpRequest: String){
        let http: HTTPManager = HTTPManager();
        
        let url: URL = URL(string: httpRequest)!;
        
        http.retrieveURL(url){
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else {return}
            print("JSON: ", json);
            
            do{
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: []);
                guard
                    let jsonObject = jsonObjectAny as? [String: Any],
                    let answer = jsonObject["dataset"] as? String else{
                        return;
                }
                self!.messagesArray.append(ChatMessage(text: "Hello, I am NLTK based bot. Model: " + answer, isIncoming: true))
                self!.messageTableView.reloadData();
                self!.scrollToBottom();
            }catch{
                print("Can't serialize data.");
            }
        }
    }
}


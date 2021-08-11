//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var message:[Message] = [
        Message(sender: "sagar.m0322@gmail.com",body: "hey wsuup"),
        Message(sender: "sagar@gmail.com",body: "what"),
        Message(sender: "sagar123@gmail.com",body: "hey "),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = C.appName
        //tableView.delegate = self
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: C.cellNibName, bundle: nil), forCellReuseIdentifier: C.cellIdentifier)
        loadMessages()

    }
    
    func loadMessages() {
        
        db.collection(C.FStore.collectionName).order(by: C.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            
            self.message = []
            
            if let e = error {
                print("there is an issue in retriving the data")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[C.FStore.senderField] as? String, let messageBody = data[C.FStore.bodyField] as? String{
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.message.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.message.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text,let messageSender = Auth.auth().currentUser?.email{
            db.collection(C.FStore.collectionName).addDocument(data: [C.FStore.senderField: messageSender,C.FStore.bodyField: messageBody,
                                                                      C.FStore.dateField: Date().timeIntervalSince1970]) { (error) in
                if let e = error {
                    print("ther was an issue saving data ,\(e)")
                }else {
                    print("data saved successfull")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
//                self.messageTextfield.text = ""
            }
            
        }
    }
    

    @IBAction func LogoutPress(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
      
    }
}


extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = message[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.cellIdentifier, for: indexPath ) as! MessageCell
        cell.label.text = message[indexPath.row].body
        
        if messages.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.MessageBubble.backgroundColor = UIColor(named: C.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: C.BrandColors.purple)
        }else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.MessageBubble.backgroundColor = UIColor(named: C.BrandColors.purple)
            cell.label.textColor = UIColor(named: C.BrandColors.lightPurple)
        }
        
        
        return cell 
    }
}

//extension ChatViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
//}

//
//  DetailChatViewController.swift
//  Speak now
//
//  Created by Nha T.Tran on 6/11/17.
//  Copyright © 2017 Nha T.Tran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    var currentContact: Contact?
    var messages = [Message]()

    var isTheFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = currentContact?.name
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.collectionView?.backgroundView = UIView(frame:(self.collectionView?.bounds)!)
        self.collectionView?.backgroundView!.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        if isTheFirstLoad == true{
            isTheFirstLoad = false
            loadMessage()

        }
        
        
        
        setupInputComponents()
        viewScrollButton()
    }
    
   
    
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        // Handle the tap gesture
        
        self.view.endEditing(true)
        
        
        
    }
    
    
    
    func viewScrollButton() {
        let lastItem = collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        if (lastItem >= 0){
            let indexPath: IndexPath = IndexPath.init(item: lastItem, section: 0) as IndexPath
            print("lastItem: \(indexPath.row)")
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }

    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.white
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
   
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
        
        let message = messages[indexPath.item]
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32

        if message.fromId != Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = UIColor.lightGray//(red:229, green: 232, blue:232, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
            cell.profileImageView.image = currentContact?.avatar
            
        }
        else {
            cell.bubbleView.backgroundColor = UIColor.blue //(red:30, green: 136, blue: 229, alpha: 1.0)
            cell.textView.textColor = UIColor.white

            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        }
        

        
        if (message.text != nil){
        cell.textView.text = message.text
        }else{
            cell.textView.text = "error"
        }
        //lets modify the bubbleView's width somehow???
        
        
        return cell
    }
    
    func handleAvatarTap(gesture: UIGestureRecognizer){
        print("tapped")
        //self.performSegue(withIdentifier: "SegueProfile", sender: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //get estimated height somehow????
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "SegueProfile", sender: nil)

    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.layer.borderColor = UIColor(red: 213/255,green: 216/255,blue: 220/255,alpha: 1.0).cgColor
        containerView.layer.borderWidth = 1.0
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //ios9 constraint anchors
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -40.0).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.backgroundColor = UIColor.blue
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func handleSend() {
            saveMessage(receiceId: (currentContact?.id)!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadMessage(){
        
        
        if let user = Auth.auth().currentUser{
            
            let queryRef = Database.database().reference().child("message/private").observe(.value, with: { (snapshot) -> Void in
                for item in snapshot.children {
                    let receiveUser = item as! DataSnapshot
                    let uid = receiveUser.key
                    
                    if uid.range(of:user.uid) != nil{
                        
                        let listId = uid.components(separatedBy: " ")
                        
                        if listId[0] == self.currentContact?.id || listId[1] == self.currentContact?.id{
                            
                            self.messages.removeAll()

                            for msg in receiveUser.children{
                                
                                let userDict = (msg as! DataSnapshot).value as! [String:AnyObject]
                                
                                if userDict.count >= 3{
                                    let sender = userDict["sender"] as! String
                                    let text = userDict["text"] as! String
                                    let time = userDict["time"] as! TimeInterval
                                    
                                    self.messages.append(Message(fromId: sender, text: text, timestamp: time))
                                    
                                    
                                    self.collectionView?.reloadData()
                                    self.viewScrollButton()
                                }
                                
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
            })
            
        }
        
    }
    
    
    func saveMessage(receiceId: String){
        
        let user = Auth.auth().currentUser
        
        var child : String?
        if (user?.uid)! > receiceId{
            child = (user?.uid)! + " " +  receiceId
        }else{
             child = receiceId + " " + (user?.uid)!
        }
        
        let userRef = Database.database().reference().child("message").child("private").child(child!)
        let childRef = userRef.childByAutoId()
        if (user?.uid)! != nil && inputTextField.text != nil && Date.timeIntervalBetween1970AndReferenceDate != nil{
            childRef.child("sender").setValue((user?.uid)!)
            childRef.child("text").setValue(inputTextField.text)
            childRef.child("time").setValue(Date.timeIntervalBetween1970AndReferenceDate)
            
            //messages.append(Message(fromId: user!.uid, text: inputTextField.text!, timestamp: Date.timeIntervalBetween1970AndReferenceDate))
        }
        
        self.messages.removeAll()
        inputTextField.text = ""
            }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.collectionView?.endEditing(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueProfile"{
            let des = segue.destination as! ProfileVC
            des.currentID = (currentContact?.id)!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
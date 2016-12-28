//
//  ChatLogController.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-20.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var cellId = "cellId"
    
    var friend: Friend?{
        //when this var is assigned a value then set
        didSet{
            //nav bar title = friend's name
            navigationItem.title = friend?.name
            //assigning the messages into an array and downcasting to [Messages] to match types
            messages = friend?.messages?.allObjects as? [Message]
            //sorting messages in decending order
            messages?.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedAscending })

            
        }
        
    }
    
    var messages: [Message]?
    
    let messageInputContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
        
    }()
    
    let inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "message..."
        return textField
        
    }()
    //dont need lazy var in iOS10 i guess...
    let sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //adds a action that calls the handleSend() when touchUpInside(pressed)
        button.addTarget(self, action: #selector(handleSend), for: UIControlEvents.touchUpInside)
        return button
        
    }()
    
    //creating a get context that will return a NSManagedObjectContext
    //like reference in firebase or query in parse...refers to a method in appDelegate which handles core data
    func createGetContext() -> NSManagedObjectContext{
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        
        return (appDelegate?.persistentContainer.viewContext)!
        
    }

    
    func handleSend() {
        
        print(inputTextField.text!)
        
        let context = createGetContext()
        
        let message = FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
        do {
            
            try context.save()
            messages?.append(message)
            let item = messages!.count - 1
            let insertionIndexPath = NSIndexPath(item: item, section: 0)
            
            collectionView?.insertItems(at: [insertionIndexPath as IndexPath])
            collectionView?.scrollToItem(at: insertionIndexPath as IndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
            
        }catch let err {
            print(err)
        }
        
    }
    
    //simulated message sent by friend
    func simulate() {
        
        let context = createGetContext()
        //creating the message
        let message = FriendsController.createMessageWithText(text: "Test message that will appear when you press simulate!", friend: friend!, minutesAgo: 1, context: context, isSender: false)
        
        do {
            //saving the message
            try context.save()
            //appending the message to the array
            messages?.append(message)
            //sorting the array based on time
            messages = messages?.sorted(by: ({$0.date!.compare($1.date! as Date) == .orderedAscending}))
            
            //inserting the message into the collectionView
            if let item = messages?.index(of: message) {
                
                //figuring out where the message is in the array
                let recievingIndexPath = NSIndexPath(item: item, section: 0)
                //inserting it in the collectionView based on its indexPath in the array
                collectionView?.insertItems(at: [recievingIndexPath as IndexPath])

                
            }
            
        } catch let err {
            
            print(err)
        }
        
    }
    
    //Variable used to play around with the bottom constraint of the messageInputContainerView
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        
        //hide tab bar
        tabBarController?.tabBar.isHidden = true
        //background color to white from black
        collectionView?.backgroundColor = UIColor.white
        //registering the cell
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        //adds a constraint that pins the messageInputContainerView to the bottom of the view
        //we need this var so we can move the messageInputContainerView up and down when keyboard shows up by playing with the constant parameter
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        view.addConstraint(bottomConstraint!)

        
        setupInputComponents()
        
        //all new coding names in iOS10
        //bring out the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //hide the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


    }
    
    //handles the keyboard which is called by NotificationCenter
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboarFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            //bool whose equivalents are assigned to both notification names
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            //changing the bottom constraint of messageInputContainerView to match the top of the keyboard
            //constant = isKeyboardShowing = name1 = -(keyboardFrame!.height) else name2 = 0
            //if else statements
            bottomConstraint?.constant = isKeyboardShowing ? -(keyboarFrame!.height) : 0
            
            //animate the lowering of messageInputContainerView so it goes same time as the keyboard dismissal
            //only 1 line of code self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                //animates so it moves the bottom cell to the top of the keyboard. find the last item and assign it to the indexPath var, then use the .scrollToItem() to scroll to it
                
                if isKeyboardShowing {
                    let indexPath = NSIndexPath(item: self.messages!.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
                }
                
            })
            
        }
        
    }
    
    private func setupInputComponents() {
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        //adding components into the messageInputContainerView
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        //adding the constraints
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //hides the keyboard
        inputTextField.endEditing(true)
    }
    
    //number of cells = messages.count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            
            return count
            
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        cell.messageTextView.text = messages?[indexPath.item].text
        
        //getting an estimated height for the cells depending on length of the textView.text
        //we use the NSString().boundingRect() to get the estimatedFrame.height. Context is almost always nil.
        //unwrapping message?[indexPath.item] so the code is not redudant
        if let message = messages?[indexPath.item],
            let messageText = message.text,
            let profileImageName = message.friend?.profileImageName {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            //arbitrary maximum height of 1000 and width of 250
            let size = CGSize(width: 250, height: 1000)
            //options neccesary to calculate the estimatedFrame(used in second parameter of the boundingRect())
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            //if false then text message alligned to left, if right then blue background and alligned to right
            if !message.isSender {
            
                //+ 16 width so it wraps at the bottom without getting cut off and +20 for height so cells dont overlap +8 X so it doesnt hug the left side
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                //we use the same frame as the text view +8 width so messages dont hug the right side of bubble
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                    
                cell.profileImageView.isHidden = false
                    
//                cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage

                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                
                cell.messageTextView.textColor = UIColor.black

                //it is important to set the attributes on both sides of the else statement because when the text is recycled it may not go back to default
                
            } else {
                
                //OUTGOING SENDING MESSAGE
                //moving the textview to the right end, the x constraint constant must match the width constraint constant and additional -8 so it doesnt hug the right wall
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)

                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                
//                cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)          
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)

                
                cell.messageTextView.textColor = UIColor.white


            }
        }

        
        
        
        return cell
    }
    //size of the cell depends on size of message
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //getting an estimated height for the cells depending on length of the textView.text
        //we use the NSString().boundingRect() to get the estimatedFrame.height. Context is almost always nil.
        //also unwrapping the profileImageName here
        if let messageText = messages?[indexPath.item].text {
            
            //arbitrary maximum height of 1000 and width of 250
            let size = CGSize(width: 250, height: 1000)
            //options neccesary to calculate the estimatedFrame(used in second parameter of the boundingRect())
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            //+ 20 so the cells dont overlap with each other.
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        //If no messages
        return CGSize(width: view.frame.width, height: 100)
    }
    //moving the inset of the top cell down 8 pixels so it doesnt hug the top,  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
}

class ChatLogMessageCell: BaseCell {
    
    //setting up the chat bubble
    let textBubbleView: UIView = {
        
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
        
    }()
    //setting up the textView
    let messageTextView: UITextView = {
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample Text."
        textView.backgroundColor = UIColor.clear
        return textView
        
    }()
    //setting up the profileImage of your chat partner
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15 //half of the size so you can get a round frame
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        
        let imageView = UIImageView()
        //.resizableImage() stretches the image to fit the chat bubble, withRenderingMode changes the color
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
        
    }()
    
    override func setupViews() {
        super.setupViews()
        
        //adding textBubbleView first so it appears behind the messageTextView
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        addSubview(profileImageView)
        //8 constant bumping the object to the right
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        
        profileImageView.backgroundColor = UIColor.red
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)

    }
    
}












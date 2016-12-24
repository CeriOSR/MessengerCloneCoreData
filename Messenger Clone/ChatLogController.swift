//
//  ChatLogController.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-20.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //background color to white from black
        collectionView?.backgroundColor = UIColor.white
        //registering the cell
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample Text."
        textView.backgroundColor = UIColor.clear
        return textView
        
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.lightGray
        
        addSubview(messageTextView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: messageTextView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: messageTextView)

    }
    
}

//
//  FriendsController.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-17.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit


//FlowLayout is needed when customizing a class or its members
class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var messages: [Message]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Recent"
        
        collectionView?.backgroundColor = UIColor.white
        //makes it bounce up and down
        collectionView?.alwaysBounceVertical = true
        //registering the cell class for use on your collectionView
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        //call this func to fill the cells
        setupData()
        
    }
    //needed for collectionView: number of cells (no need to call the number of section when you only need 1)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //safely unwrapping the messages array because messages is an optional
        if let count = messages?.count {
            
            return count
        }
        
        return 0
    }
    //needed for collectionView: calls the cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        //safely unwrapping, applying messages into the cell message variable
        if let message = messages?[indexPath.item] {
            
            cell.message = message
        }
        
        return cell
        
    }
    
    //accessable when you declare the UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //cells width = frame.width and height = 100
        return CGSize(width: view.frame.width, height: 100)
    }



}

class MessageCell: BaseCell {
    //if this is set, cell.nameLabel.text will equal [indexPath.item]
    var message: Message? {
        
        didSet{
            nameLabel.text = message?.friend?.name
            //safely unwrapping the optional messages and friend
            if let profileImageName = message?.friend?.profileImageName {
                
                profileImageView.image = UIImage(named: profileImageName)
                
            }
            
            messageLabel.text = message?.text
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
            
        }
        
    }
    
    //creating an profileImageView
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        //half of the size which will give you a round circle
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    let dividerLineView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
        
    }()
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Friend's name"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
        
    }()
    
    let messageLabel: UILabel = {
        
        let label = UILabel()
        label.text = "This is the message area....get out!"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = NSTextAlignment.right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
 
    }()

    
    
    //override so we can use it in this class
    override func setupViews() {
        
        //adding the adding the subViews into the superView to the cell heirarchy
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        profileImageView.image = UIImage(named: "photo_ardan")
        hasReadImageView.image = UIImage(named: "photo_ardan")

        
        //adding Horizontal constaints for the profileImageView (need to study more about withVisualFormat...)
        //"H:|-12-[v0(68)]|" = -12 spacing horizontally, (68) = size
        addConstraintsWithFormat(format: "H:|-12-[v0(68)]|", views: profileImageView)
        //adding Vertical constraints for the profileImageView
        addConstraintsWithFormat(format: "V:|-12-[v0(68)]|", views: profileImageView)
        
        //centering the profileImageView vertically regardless of cell size
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //dividerLineView constraints    //82 pixels away from left side
        addConstraintsWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        //1 pixel thick vertically and no pipe at the left so it hugs the bottom...
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
    }
    
    private func setupContainerView() {
        
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
        
        //centering the containView vertically regardless of cell size
        addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        
        //12 constant padding on the right of timeLabel
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        //2 views in 1 vertical constaint. message label is 24 in height
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        //12 pixel constant padding to the right, 8 constant padding between both views, v1 is 20 width
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        //pipe at left to hug the top
        containerView.addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        //pipe at the right to keep it hugging the bottom
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
        
    }
    
}



extension UIView {
    
    //this function condenses this code because we have to use this method on every subViews
    /*
     //adding Horizontal constaints for the profileImageView (need to study more about withVisualFormat...)
    //"H:|-12-[v0(68)]|" = -12 spacing horizontally, (68) = size
     
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[v0(68)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": profileImageView]))
    */
    
    //UIView... means you can specify 0 or 1 or as many views...
    func addConstraintsWithFormat(format: String, views: UIView...) {
        //have to do translatesAutoresizingMaskIntoConstraints to apply constraints
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))

        
    }
    
    
}

class BaseCell: UICollectionViewCell {
    //Initializing the collection view cells
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
    }
    //this code is required when initializing
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        backgroundColor = UIColor.blue
        
    }


}


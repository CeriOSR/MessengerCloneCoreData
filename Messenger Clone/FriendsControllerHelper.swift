//
//  FriendsControllerHelper.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit

//classes used for the information
class Friend: NSObject {
    
    var name: String?
    var profileImageName: String?
    
}

class Message: NSObject {
    
    var text: String?
    var date: NSDate?
    
    var friend: Friend?
    
}

extension FriendsController {
    
    //func that sets up the a friend and message
    func setupData() {
        
        let ardan = Friend()
        ardan.name = "Ardan"
        ardan.profileImageName = "photo_ardan"
        
        let ardanMessage = Message()
        ardanMessage.friend = ardan
        ardanMessage.text = "Gauntlet for everybody!"
        ardanMessage.date = NSDate()
        
        let baron = Friend()
        baron.name = "Baron"
        baron.profileImageName = "photo_baron"
        
        let baronMessage = Message()
        baronMessage.friend = baron
        baronMessage.text = "Its raining missiles!"
        baronMessage.date = NSDate()

        
        
        //adding the messages into the [message]
        messages = [ardanMessage, baronMessage]
    }

}

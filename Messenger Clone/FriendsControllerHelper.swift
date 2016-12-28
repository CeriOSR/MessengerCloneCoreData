//
//  FriendsControllerHelper.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    //creating a get context that will return a NSManagedObjectContext
    //like reference in firebase or query in parse...refers to a method in appDelegate which handles core data
    func createGetContext() -> NSManagedObjectContext{
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        
        return (appDelegate?.persistentContainer.viewContext)!
        
    }
    
    
    
    //setting up the data
    func setupData(){
        
        //clearData()
        
        
        let context = createGetContext()
        
        let adagio = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        adagio.name = "Adagio"
        adagio.profileImageName = "photo_adagio"
        
        
        let glaive = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        glaive.name = "Glaive"
        glaive.profileImageName = "photo_glaive"
        
        let ringo = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        ringo.name = "Ringo"
        ringo.profileImageName = "photo_ringo"
        
        let celeste = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        celeste.name = "Celeste"
        celeste.profileImageName = "photo_celeste"
        
        createSawMessageWithContext(context: context)
        
        
        FriendsController.createMessageWithText(text: "This is boredom at its best!", friend: adagio, minutesAgo: 2, context: context)
        FriendsController.createMessageWithText(text: "Somebody! get a soda.", friend: adagio, minutesAgo: 3, context: context)
        FriendsController.createMessageWithText(text: "Im going to cut you into little pieces.", friend: adagio, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "Eat axe, bitch!!", friend: glaive, minutesAgo: 4, context: context)
        FriendsController.createMessageWithText(text: "Anybody wants to be my pingpong ball?!", friend: glaive, minutesAgo: 0, context: context)
        FriendsController.createMessageWithText(text: "Drunk right now!", friend: ringo, minutesAgo: 2, context: context)
        FriendsController.createMessageWithText(text: "Stars and Boom!", friend: celeste, minutesAgo: 60 * 24 * 8, context: context)
        
        do {
            try context.save()
            print("Saved!!!!!")
        } catch let err {
            print(err)
        }
        
        getMessages()
        
    }
    //new func that creates messages for specific friend so we can work closely with responses
    private func createSawMessageWithContext(context: NSManagedObjectContext) {
        
        let saw = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        saw.name = "Saw"
        saw.profileImageName = "photo_saw"
        
        FriendsController.createMessageWithText(text: "RatatatatatatatatataStab! I'm gonna chase you to the ends of the worlds with my boots and stab you in the back with my knife! Come back here you silly goose!", friend: saw, minutesAgo: 60 * 25, context: context)
        
        FriendsController.createMessageWithText(text: "Gatling gun Gatling gun Gatling all the way!", friend: saw, minutesAgo: 60 * 24 * 8, context: context)
        
        FriendsController.createMessageWithText(text: "lol Saw OP. Nerf or RITO! Beach balloon stab and nerf water gun spray", friend: saw, minutesAgo: 1, context: context)


        //reply message
        //adding isSender parameter and assigning a value of true.
        FriendsController.createMessageWithText(text: "Take this stun and take this...hah that was easy!", friend: saw, minutesAgo: 3, context: context, isSender: true)
        
        FriendsController.createMessageWithText(text: "You're too easy to stun pahahahahaha. Take this DPS! pahahahahaha...wait...why am I dead! damn you crucible!!!", friend: saw, minutesAgo: 2, context: context, isSender: true)


        
        
    }
    
    //static turns it into a global func that can be called by viewController.createMessageWithText()
    static func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message{
        
        //setting up the message as a Message() type and filling in the parameters
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.isSender = NSNumber(booleanLiteral: isSender) as Bool //new parameter to figure who sent the message
        return message
    }
    
    //        private func createFriend(name: String, profileImage: String, context: NSManagedObjectContext) {
    //
    //            let friend = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
    //            friend.name = name
    //            friend.profileImageName = profileImage
    //    
    //        }

    
    //fetching the messages
    func getMessages() {
        
        if let friends = fetchFriends() {
            
            messages = [Message]()
            
            for friend in friends {
                print(friend.name!)
        
                //create a fetch request, telling it about the entity
                let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                //sort the array by time/date
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                //filtering the pull with friend's name equal to friend.name!
                fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                //limit pull to 1 item
                fetchRequest.fetchLimit = 1
                
                do {
                    //go get the results and add to array for display
                    let fetchedMessages = try createGetContext().fetch(fetchRequest) as [Message]
                    //messages = try createGetContext().fetch(fetchRequest) as [Message]
                    
                    //appending the messages into the message array
                    messages?.append(contentsOf: fetchedMessages)
                    //messages?.append(contentsOf: fetchedMessages!)
                    
                } catch {
                    print("Error with request: \(error)")
                }
                //sorting the messages array...throwing a nil...need to fix
                messages?.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedDescending })
                
            }
        }
    }
    
    func clearData() {
        
        //create a fetch request, telling it about the entity
        let fetchRequestMessage: NSFetchRequest<Message> = Message.fetchRequest()
        
        let fetchRequestFriend: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {
            //running the fetch request and adding to the array.
            friends = try createGetContext().fetch(fetchRequestFriend) as [Friend]
            
            for friend in friends! {
                //looping and deleting
                createGetContext().delete(friend)
            }
            
            //go get the results and add it to an Array to be deleted
            messages = try createGetContext().fetch(fetchRequestMessage) as [Message]
            
            for message in messages! {
                //loop through array and delete every message
                createGetContext().delete(message)
                
            }
            //have to save the context after deleting
            try (createGetContext().save())
            
        } catch {
            print("Error with request: \(error)")
        }
        
    }
    //delete the everything, (bug: does not display anything on the tableView if run)
    func batchDelete() {
        
        let fetchRequestMessage: NSFetchRequest<Message> = Message.fetchRequest()
        
        let fetchRequestFriend: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        let requestFriend = NSBatchDeleteRequest(fetchRequest: fetchRequestFriend as! NSFetchRequest<NSFetchRequestResult>)
        
        let requestMessage = NSBatchDeleteRequest(fetchRequest: fetchRequestMessage as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            
            try createGetContext().execute(requestFriend)
            try createGetContext().execute(requestMessage)
            
            
        } catch let err {
            
            print(err)
        }
    }
    
    //pulling friends to be assigned to a friends array
    private func fetchFriends() -> [Friend]? {
        //creating a fetch request
        let fetchRequestFriend: NSFetchRequest<Friend> = Friend.fetchRequest()
        
        do {
            
            //running the fetch request as type friend in an array
            return try createGetContext().fetch(fetchRequestFriend) as [Friend]?
            
        } catch let err {
            
            print(err)
        }
        
        return nil
        
    }
        
}

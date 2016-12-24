//
//  CustomTabBarController.swift
//  Messenger Clone
//
//  Created by Rey Cerio on 2016-12-21.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit


class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup our custom view controllers
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "photo_recent")
        
        //instantiate this property as an array of viewControllers that gets called when you press a tabBarItem
        viewControllers = [recentMessagesNavController, createDummyNavControllersWithTitle(title: "Calls", imageName: "photo_calls"), createDummyNavControllersWithTitle(title: "Groups", imageName: "photo_groups"), createDummyNavControllersWithTitle(title: "People", imageName: "photo_people"), createDummyNavControllersWithTitle(title: "Settings", imageName: "photo_settings")]
        
    }
    
    //creating a navigation controll that is being called after pressing a tabBarItem button
    private func createDummyNavControllersWithTitle(title: String, imageName: String) -> UINavigationController {
        
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController
        
    }
    
    
}

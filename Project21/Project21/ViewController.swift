//
//  ViewController.swift
//  Project21
//
//  Created by Rishi Chhabra on 16/08/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController,UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options:[.alert,.badge,.sound]) { granted, error in
            if granted {
                print("registered")
            } else {
              print("Problem Registering")
            }
        }
        
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake Up Call"
        content.body = "Early birds get the worm, but the second mouse gets the cheese!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData" : "fizzbuzz"]
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
    }
    
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell Me More",options: .foreground)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [],options: [])
        
        center.setNotificationCategories([category])
        
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom Data Received \(customData)")
            
            switch response.actionIdentifier {
            case "show":
                print("show more information")
            default:
                break
            }
        }
        
        completionHandler()
    }

}


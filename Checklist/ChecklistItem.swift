//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-02.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import Foundation
import UserNotifications

class checklistItem: NSObject, NSCoding {
    
    var text = ""
    var checked = false
    
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int
    
    func toggleChecked() {
        checked = !checked
    }
    
    // load files
    required init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(forKey: "Text") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        
        dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        super.init()
    }
    
    // save files
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(checked, forKey: "Checked")
        
        aCoder.encode(dueDate, forKey: "DueDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(itemID, forKey: "ItemID")
    }
    
    override init() {
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "Reminder:"
                content.body = text
                content.sound = UNNotificationSound.default()
                
                let calender = Calendar(identifier: .gregorian)
                let components = calender.dateComponents([.month, .day, .hour, .minute], from: dueDate)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let requeset = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(requeset)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func removeNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
        } else {
            // Fallback on earlier versions
        }
    }
    deinit {
        removeNotification()
    }
}

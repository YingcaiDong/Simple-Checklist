//
//  DataModel.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-30.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import Foundation

class DataModel {
    var lists = [Checklist]()
    
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = UserDefaults.standard.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    //=======================
    // creat a dataFile path
    //=======================
    // get document path
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    // get dataFile path
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("Checklists.plist")
    }
    
    //=======================
    //      store data
    //=======================
    func saveChecklists() {
        // mutableData 字符数据
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    //=========================
    //      load data
    //=========================
    func loadChecklists() {
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                lists = unarchiver.decodeObject(forKey: "Checklists") as! [Checklist]
                unarchiver.finishDecoding()
            }
        }
        // make sure the existing lists are sorted
        sortChecklists()
    }
    
    func registerDefalts() {
        // add a init value for 'ChecklistIndex' for UserDefaults
        // prevent first time app open crash
        let dictionary: [String: Any] = ["ChecklistIndex": -1,
                                         "FirstTime": true,
                                         "ChecklistItemID": 0]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    // define how to sort the checklist by name
    func sortChecklists() {
        lists.sort(by: {checklist1, checklist2 in return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending})
    }
    
    // This makes sure that, as soon as the DataModel object is created, it will attempt to load Checklists.plist.
    init() {
        loadChecklists()
        registerDefalts()
        handleFirstTime()
    }
}

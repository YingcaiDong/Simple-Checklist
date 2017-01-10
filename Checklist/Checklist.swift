//
//  Checklist.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-10.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import UIKit

// if use NSCoding, then it is forced to use 2 additional method
// init?(coder)
// encodeWithCoder()
class Checklist: NSObject, NSCoding {
    var name = ""
    // init an array that is ChecklistItem data type
    var items = [checklistItem]()
    
    var iconName: String
    
    init(name: String) {
        self.name = name
        iconName = "No Icon"
        super.init()
    }
    
    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    // load data
    // 在此定义解码格式
    required init?(coder aDecoder: NSCoder) {
        // as 后面跟要转换成的数据类型
        // 数据类型是变量名最开始定义的类型
        name = aDecoder.decodeObject(forKey: "Name") as! String
        items = aDecoder.decodeObject(forKey: "Items") as! [checklistItem]
        iconName = aDecoder.decodeObject(forKey: "IconName") as! String
        super.init()
    }
    
    // save data
    // 在此定义编码格式
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(items, forKey: "Items")
        aCoder.encode(iconName, forKey: "IconName")
    }
    
    func countUncheckedItems() -> Int {
        var count = 0
        for item in items where !item.checked {
            count += 1
        }
        return count
    }
    
    // define sort checklist item by name
    func sortItemByName() {
        items.sort(by: {checklistItem1, checklistItem2 in return checklistItem1.text.localizedStandardCompare(checklistItem2.text) == .orderedAscending})
    }
    // define sort checklist item by due date
    func sortItemByDate() {
        var itemNoDate = [checklistItem]()
        var itemWithDate = [checklistItem]()
        for item in items {
            if !item.shouldRemind {
                itemNoDate.append(item)
            } else {
                itemWithDate.append(item)
            }
        }
        itemWithDate.sort(by: {checklistItem1, checklistItem2 in return checklistItem1.dueDate.compare(checklistItem2.dueDate) == .orderedAscending})
        items = itemWithDate + itemNoDate
        
    }
    // define sort checklist item by check mark
    func sortItemByChcekmark() {
        var itemChecked = [checklistItem]()
        var itemUnChecked = [checklistItem]()
        for item in items {
            if item.checked {
                itemChecked.append(item)
            } else {
                itemUnChecked.append(item)
            }
        }
        itemChecked.sort(by: {itemChecked1, itemChecked2 in return itemChecked1.text.localizedStandardCompare(itemChecked2.text) == .orderedAscending})
        itemUnChecked.sort(by: {itemUnChecked1, itemUnChecked2 in return itemUnChecked1.text.localizedStandardCompare(itemUnChecked2.text) == .orderedAscending})

        items = itemChecked + itemUnChecked
    }
    
}

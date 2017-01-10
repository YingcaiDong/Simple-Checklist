//
//  ItemDetailViewController.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-03.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: class {
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: checklistItem)
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: checklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: ItemDetailViewControllerDelegate?
    
    var dueDate = Date()
    
    var datePickerVisable = false
    
    // if user want to edite checklist item, then this variable will be initialized
    var itemToEdit: checklistItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
        updateDueDateLabel()
    }
    
    // when the textField appears, pop up the keyboard.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisable {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath.row = 0
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // draw shadows on row when press it
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 && shouldRemindSwitch.isOn {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1 && shouldRemindSwitch.isOn {
            if !datePickerVisable {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        
        if let item = itemToEdit {
            item.text = textField.text!
            
            item.dueDate = dueDate
            item.shouldRemind = shouldRemindSwitch.isOn
            
            item.scheduleNotification()
            
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
            
        } else {
            let item = checklistItem()
            item.text = textField.text!
            item.checked = false
            
            item.dueDate = dueDate
            item.shouldRemind = shouldRemindSwitch.isOn
            
            item.scheduleNotification()
            
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        // update global var
        dueDate = sender.date
        
        // update the label
        updateDueDateLabel()
    }
    
    
    @IBAction func switchToDispDatePicker(_ sender: UISwitch) {
        textField.resignFirstResponder()
        
        if sender.isOn {
            showDatePicker()
            
            // when first time switch on, ask the notification permission
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) {
                    granted, error in
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            hideDatePicker()
        }
    }
    
    
    
    // disable the done button when init nothing put in the textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let initString: NSString = textField.text! as NSString
        doneBarButton.isEnabled = (initString.length>0)
        
        hideDatePicker()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldTextString:NSString = textField.text! as NSString
        let newTextString:NSString = oldTextString.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newTextString.length > 0)
        
        return true
    }
    
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        // modify dispaly date formate
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func showDatePicker() {
        datePickerVisable = true
        
        // going to high light it when tapping
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        // tells the uidatePicker to insert a new row below the Due Date cell
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        // ensure they animated in the same time
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        
        datePicker!.setDate(dueDate, animated: true)

    }
    
    func hideDatePicker() {
        if datePickerVisable {
            datePickerVisable =  false
            
            let indexPathDateRow = IndexPath(row: 1, section: 1)
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            
            // change Data Row colour back to default blue
            tableView.cellForRow(at: indexPathDateRow)?.detailTextLabel?.textColor = UIColor.init(white: 0, alpha: 0.5)
            
            tableView.beginUpdates()
            // hide the Date Picker cell
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.endUpdates()
        }
    }
    
}

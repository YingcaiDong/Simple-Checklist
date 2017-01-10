//
//  ListDetailViewController.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-15.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
    
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAddingChecklist list: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditingChecklist list: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {

    // used for input text or modify the text
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var iconImageView: UIImageView!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    // need to unrap it
    // transfer "need to edit checklist" via delegate
    // like a signal from other object
    var checklistEdit: Checklist?
    
    // use this variable to keep track of the chosen icon name
    var iconName = "Folder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checklist = checklistEdit {
            title = "Edit Chceklist"
            textField.text = checklist.name
            doneBarButton.isEnabled = true
            iconName = checklist.iconName
        }
        // first time use
        // when the app init
        // provid init image
        iconImageView?.image = UIImage(named: iconName)
    }
    
    // pop up the keyboard immediately
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textField.becomeFirstResponder()
    }
    
    // make sure the textFiled is un-shadowed(return nil)
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // delagate function
    // segue prepare
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        //list detail view controller's iconName = function iconName
        self.iconName = iconName
        // second time use
        // update the image when new image selected
        iconImageView?.image = UIImage(named: iconName)
        let _=navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
            
        }
    }
    
    // add the cancle button
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    // add the edit function
    @IBAction func done() {
        // if receive the signal flag
        if let checklist = checklistEdit {
            checklist.name = textField.text!
            checklist.iconName = iconName
            // use delegate
            delegate?.listDetailViewController(self, didFinishEditingChecklist: checklist)
        } else { // adding check list
            let checklist = Checklist(name: textField.text!, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAddingChecklist: checklist)
        }
    }
    
    // if the textfield is replaced with empty, then the done button is disabled
    // otherwise is enabled
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldString: NSString = textField.text! as NSString
        let newString: NSString = oldString.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = newString.length > 0
        
        return true
    }

}

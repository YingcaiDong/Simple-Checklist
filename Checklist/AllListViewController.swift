//
//  AllListViewController.swift
//  Checklist
//
//  Created by Yingcai Dong on 2016-09-08.
//  Copyright © 2016 Yingcai Dong. All rights reserved.
//

import UIKit

// To recognize whether the user presses the back button on the navigation bar, you have to become a delegate of the navigation controller. Being the delegate means that the navigation controller tells you when it pushes or pops view controllers on the navigation stack.
// that's why UINavigationControllerDelage is included here.
class AllListViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {

    // 这段声明的意思是变量 dataModel 会在未来被赋值
    // swift 中所有变量、常量都必须有一个值
    // 因为 dataModel 的 data type 是 DataModel！为强制解包，必然存在的一个 class，所以必须有一个非 nil 的值在此段声明之后，其他函数调用此变量前对 dataModel 赋一个非 nil 的值
    // 因为在后面的 function 中已近使用了这个变量，所以如果变量为 nil， 程序会崩溃
    var dataModel: DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("1. viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // Check at startup which checklist you need to show and then perform the segue manually.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("2. viewDidAppear")
        // AllListViewController 作为 navigationController 的代理
        // 此处的 navigationController 应该是AllLIstViewController 左侧链接的那个界面
        // 一旦代理被初始化，那么 protocol 中的 function 将会被调用（在需要的时候）
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist // {get}
        if index >= 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            // segue will be triggered
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModel.lists.count
    }

    // init cell
    func cellForTableView(_ tableView: UITableView) -> UITableViewCell {
        let cellIdentifer = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer) {
            return cell
        } else {
            // subtitle:
            // A style for a cell with a left-aligned label across the top and a left-aligned label below it in smaller gray text. The iPod application uses cells in this style.
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifer)
        }
    }
    
    // load content to cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = cellForTableView(tableView)
        
        let checklist: Checklist = dataModel.lists[indexPath.row]
        cell.textLabel!.text = checklist.name
        
        // customise the table view style
        cell.accessoryType = .detailDisclosureButton
        let count = checklist.countUncheckedItems()
        if checklist.items.count == 0 {
            cell.detailTextLabel!.text = "(No Items)"
        } else if count == 0 {
            cell.detailTextLabel!.text = "All Done!"
        } else {
            cell.detailTextLabel!.text = "\(count) Remaining"
        }
        // display a image at the left of the cell
        cell.imageView!.image = UIImage(named: checklist.iconName)
        print("cell for row at indexPath")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // stroe which row user pressed
        // if the app suspended, when reopen the app, history restored, user can start from where it paused
        dataModel.indexOfSelectedChecklist = indexPath.row // {set}
        
        let checklist = dataModel.lists[indexPath.row]
        
        // Note that the new segue isn’t attached to any button or table view cell.
        // There is nothing on the All Lists screen that you can tap or otherwise interact with in order to trigger this segue. That means you have to perform it programmatically.
        // Previously, a tap on a row would automatically perform the segue because you had hooked up the segue to the prototype cell. However, the table view for this screen isn’t using prototype cells and therefore you have to perform the segue manually.
        // pass the object to the checklist view controller
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        
        print("3. tableView didSelectRowAt indexPath(performSegue: \(checklist.name))")
    }
    
    // delete one selected checklist
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // delete from the data file
        dataModel.lists.remove(at: indexPath.row)
        
        // then delete from the table view
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // link detail info button to the 'listDetailViewController' navigationController
    // this time is to link a segue to an customed storyboard via code
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        // similar steps as prepare segue
        let navigationController = storyboard!.instantiateViewController(withIdentifier: "ListDetailNavigationController") as! UINavigationController
        let controller = navigationController.topViewController as! ListDetailViewController
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistEdit = checklist
        
        present(navigationController, animated: true, completion: nil)
    }
    
    
    //===========================================
    // setup ListDetailView delegate function
    //===========================================
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAddingChecklist list: Checklist) {
        
        // saving income data 'list' to the file
        dataModel.lists.append(list)
        
        // sort the checklist by name order
        // sortChecklists method decleared in dataModel
        dataModel.sortChecklists()
        
        // reload all the data, update all property
        tableView.reloadData()
        
        // after all above, dismiss this table view window
        dismiss(animated: true, completion: nil)
        
        print("4. listDeatilView delegate didFinishAddingChecklist")
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditingChecklist list: Checklist) {
        // sort checklists by name order
        dataModel.sortChecklists()
        
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
        
        print("5. listDeatilView delegate didFinishEditingChecklist")
    }
    
    //===========================================
    // setup UINavigationController delegate function
    //===========================================
    //This method is called whenever the navigation controller will slide to a new screen.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // when this new screen == AllListViewController(self)
        // 注意是三连等号
        // If you use ==, you’re checking whether two variables have the same value.
        // With === you’re checking whether two variables refer to the exact same object.
        if viewController === self {
            // remove the previous stored value from the NSUserDefaults by setting the value to -1
            dataModel.indexOfSelectedChecklist = -1 // {set}
        }
        
        print("6. navigationController willShow viewController")
    }
    
    // prepare segue
    // the stroy board is known
    // but only to distinguish the different use of segue
    // 此时的 sender 已经被 preformSegueWithIdentifer 初始化为 AllListViewController 中要传递的 checklist 了
    // 但是还是要强制转换成 Checklist 的数据类型（虽然此时的 sender 里面已经是这个数据类型了）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("7. prepare for segue")
        if segue.identifier == "ShowChecklist" {
            // link with CheckListViewController object
            let controller = segue.destination as! CheckListViewController
            controller.checklist = sender as! Checklist
            
        } else if segue.identifier == "AddChecklist" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ListDetailViewController
            controller.delegate = self
            controller.checklistEdit = nil
            
        }
    }
}



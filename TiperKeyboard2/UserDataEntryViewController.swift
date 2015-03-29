//
//  UserDataEntryViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class UserDataEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView : UITableView?
    var selectedRow = 0
    var count = 0
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var keyArray = [[String:String]]()
    let cellIdentifier = "UserDataTableViewCell"
    let defaultskey = "tiper2Keyboard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Set Up Your Keyboard Keys"
        
        /*
        TODO 
        1 - add a how to screen to get user to enable the keyboard
        2 - add an animation to the table view cells when it is saved
            -- add a checkmark view to indicate it has been saved
        3 - choose a color to color code the individual keys
            -- add an edit button the left side
            -- push to a different color picker screen
        4 - replace all cell delegate protocols with closures
        */
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveData")
        
        if self.sharedDefaults?.objectForKey(defaultskey) != nil {
            self.keyArray = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
            self.count = self.keyArray.count
            self.tableView?.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getSelectedRow:", name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveData", name: UITextFieldTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)

        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width+300, self.view.frame.size.height), style: UITableViewStyle.Plain)
        self.tableView?.registerClass(UserDataCellTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView?.contentInset = UIEdgeInsetsMake(0, -300, 0, 0)
        self.view.addSubview(self.tableView!)
        
        self.tableView?.autoresizesSubviews = false
    }
    
    func addNewItem () {
        self.count++
        self.keyArray.append(["":""])
        self.tableView?.reloadData()
        let offset = self.navigationController?.navigationBar.frame.size.height as CGFloat! + UIApplication.sharedApplication().statusBarFrame.height as CGFloat!
        self.tableView?.contentInset = UIEdgeInsetsMake(offset, -300, 0, 0)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var userDataCell = tableView.dequeueReusableCellWithIdentifier("UserDataTableViewCell") as! UserDataCellTableViewCell
        userDataCell.tag = indexPath.row
        userDataCell.userEmailTextField?.tag = indexPath.row
        userDataCell.userNameTextField?.tag = indexPath.row
        
        userDataCell.updateColorCallback = { (tag : Int) in
            println("the whate whate")
        }
        
        userDataCell.slideBeganCallback = { (tag : Int) in
            self.selectedRow = tag
            self.saveData()
        }
        
        userDataCell.deleteItemCallback = { (tag : Int) in
            self.count--
            self.keyArray.removeAtIndex(tag)
            self.sharedDefaults?.setValue(self.keyArray, forKey:self.defaultskey)
            self.sharedDefaults?.synchronize()
            
            self.tableView?.beginUpdates()
            self.tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: tag, inSection: 0)], withRowAnimation: .Left)
            self.tableView?.endUpdates()
            self.tableView?.reloadData()
        }
        
        if self.keyArray.count > indexPath.row {
            let keyDictionary = self.keyArray[indexPath.row] as [String:String]
            userDataCell.userNameTextField.text = keyDictionary.keys.array[0]
            userDataCell.userEmailTextField.text = keyDictionary.values.array[0]
        }
        
        userDataCell.backgroundColor = colorForIndex(indexPath.row)
        
        return userDataCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.height/7
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func getSelectedRow (notification:NSNotification) {
        let textField = notification.object as! UITextField
        textField.placeholder = ""
        self.selectedRow = textField.tag
        if let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0)) as? UserDataCellTableViewCell {
            cell.backgroundColor = getRandomColor()
        }
    }
    
    func textChanged (notification:NSNotification) {
        let textField = notification.object as! UITextField
    }
    
    func keyboardShown (notification:NSNotification) {
        if self.selectedRow > 2 {
            let info = notification.userInfo as! [String:AnyObject]
            let keyboardSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
            let height = keyboardSize?.height
            let insets = UIEdgeInsetsMake(0, 0, 130 + height!, 0)
            self.tableView?.contentInset = insets
            self.tableView?.scrollToRowAtIndexPath((NSIndexPath(forRow:self.selectedRow, inSection: 0)), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    func keyboardHidden (notification:NSNotification) {
        if self.selectedRow > 2 {
            self.tableView?.contentInset = UIEdgeInsetsMake(self.view.frame.size.height/7/2 + 18, 0, 0, 0)
        }
        saveData()
    }
    
    func saveData () {
        if let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0)) as? UserDataCellTableViewCell {
            if (!cell.userEmailTextField.text.isEmpty && !cell.userNameTextField.text.isEmpty) {
                let keyDictionary = [cell.userNameTextField.text : cell.userEmailTextField.text] as [String:String]
                if self.selectedRow + 1 > self.keyArray.count {
                    self.keyArray.append(keyDictionary)
                }
                else {
                    self.keyArray[self.selectedRow] = keyDictionary
                }
                self.sharedDefaults?.setValue(self.keyArray, forKey:defaultskey)
                self.sharedDefaults?.synchronize()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0)) as? UserDataCellTableViewCell {
            if cell.userNameTextField?.isFirstResponder() == true {
                cell.userNameTextField?.resignFirstResponder()
            }
            else if cell.userEmailTextField?.isFirstResponder() == true {
                cell.userEmailTextField?.resignFirstResponder()
            }
        }
    }
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func colorForIndex (index : Int) -> UIColor {
        let itemCount = count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

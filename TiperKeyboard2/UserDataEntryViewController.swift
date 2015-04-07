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
    var colorDictionary = [String:String]()
    let cellIdentifier = "UserDataTableViewCell"
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Set Up Your Keyboard Keys"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveData")
        
        if self.sharedDefaults?.objectForKey(defaultskey) != nil {
            self.keyArray = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
            self.count = self.keyArray.count
            self.tableView?.reloadData()
        }
        
        if self.sharedDefaults?.objectForKey(defaultColors) != nil {
            self.colorDictionary = self.sharedDefaults?.objectForKey(defaultColors) as! [String:String]
            
            println("\(self.colorDictionary)")
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
        userDataCell.keyInputDataTextField?.tag = indexPath.row
        userDataCell.keyNameTextField?.tag = indexPath.row
        
        weak var weakSelf = self
        userDataCell.updateColorCallback = { (keyName: String, colorIndex: String) in
            if weakSelf!.colorDictionary[keyName] != nil {
                weakSelf!.colorDictionary.removeValueForKey(keyName)
            }
            weakSelf!.colorDictionary[keyName] = colorIndex
            weakSelf!.sharedDefaults?.setValue(weakSelf!.colorDictionary, forKey: weakSelf!.defaultColors)
            weakSelf!.sharedDefaults?.synchronize()
        }
        
        userDataCell.slideBeganCallback = { (tag : Int) in
            weakSelf!.selectedRow = tag
            weakSelf!.saveData()
        }
        
        userDataCell.deleteItemCallback = { (tag : Int) in
            weakSelf!.count--
            weakSelf!.keyArray.removeAtIndex(tag)
            weakSelf!.sharedDefaults?.setValue(weakSelf!.keyArray, forKey:weakSelf!.defaultskey)
            weakSelf!.sharedDefaults?.synchronize()
            
            weakSelf!.tableView?.beginUpdates()
            weakSelf!.tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: tag, inSection: 0)], withRowAnimation: .Left)
            weakSelf!.tableView?.endUpdates()
            weakSelf!.tableView?.reloadData()
        }
        
        if self.keyArray.count > indexPath.row {
            let keyDictionary = self.keyArray[indexPath.row] as [String:String]
            userDataCell.keyNameTextField.text = keyDictionary.keys.array[0]
            userDataCell.keyInputDataTextField.text = keyDictionary.values.array[0]
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
            let insets = UIEdgeInsetsMake(0, -300, 130 + height!, 0)
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
            if (!cell.keyInputDataTextField.text.isEmpty && !cell.keyNameTextField.text.isEmpty) {
                let keyDictionary = [cell.keyNameTextField.text : cell.keyInputDataTextField.text] as [String:String]
                if self.selectedRow + 1 > self.keyArray.count {
                    self.keyArray.append(keyDictionary)
                }
                else {
                    self.keyArray[self.selectedRow] = keyDictionary
                }
                self.sharedDefaults?.setValue(self.keyArray, forKey:self.defaultskey)
                self.sharedDefaults?.setValue(self.colorDictionary, forKey:self.defaultColors)
                self.sharedDefaults?.synchronize()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRow, inSection: 0)) as? UserDataCellTableViewCell {
            if cell.keyNameTextField?.isFirstResponder() == true {
                cell.keyNameTextField?.resignFirstResponder()
            }
            else if cell.keyInputDataTextField?.isFirstResponder() == true {
                cell.keyInputDataTextField?.resignFirstResponder()
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

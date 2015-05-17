//
//  PreviewViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource, UITextFieldDelegate {
    
    var collectionView : UICollectionView?
    
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var tempData = [String:String]()
    var count = 0
    var selectedItem = 0
    var colors = [String:String]()
    var buttonArray = [UIButton]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    let colorRef = ColorPalette.colorRef
    var textFieldOne : UITextField?
    var textFieldTwo : UITextField?
    var defaultTextLabel : UILabel?
    var instructionalLabel : UILabel?
    var outPutLabel : UILabel?
    var editKeysButton : UIButton?
    var swipeGestureRecognizer : UISwipeGestureRecognizer?
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedItem = indexPath.item
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? PreviewCell
        var originalColor = cell?.backgroundColor
        
        if editKeysButton?.selected == false {
            UIView.animateWithDuration(0.2, animations: {
                cell?.backgroundColor = UIColor.lightGrayColor()
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.2, animations: {
                        cell?.backgroundColor = originalColor
                    })
            })
            var keyDict = data[indexPath.item]
            for (key, value) in keyDict {
                textFieldOne?.text = value
            }
        }
        else {
            UIView.animateWithDuration(0.5, animations: {
                for textField in [self.textFieldOne, self.textFieldTwo] {
                    textField!.alpha = 1.0
                    textField!.userInteractionEnabled = true
                    textField!.text = ""
                }
                self.textFieldTwo?.hidden = false
                self.textFieldTwo?.placeholder = "What is the name of this key?"
                self.textFieldOne?.placeholder = "What will this key type when pressed?"
                self.instructionalLabel?.text = "Press Save to Bind this Key."
                cell!.backgroundColor = UIColor.lightTextColor()
                cell!.keyTextLabel?.textColor = UIColor.darkGrayColor()
            }, completion: { (value) in
                self.collectionView?.reloadData()
            })
        }
    }
    
    func swipeDown () {
        for textField in [textFieldOne, textFieldTwo] {
            if textField!.isFirstResponder() {
                textField!.resignFirstResponder()
            }
        }
    }
    
    func textChanged (notification:NSNotification) {
        tempData = [String:String]()
        let textField = notification.object as! UITextField
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
//        if textField == textFieldOne {
//        }
//        else if textField == textFieldTwo {
//            
//        }
        tempData[textFieldOne!.text] = textFieldTwo!.text

        // reload the cell at that indexpath
        collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedItem, inSection: 0)])
        data.insert(tempData, atIndex: selectedItem)
        data.removeAtIndex(selectedItem + 1)
        println("\(data) *****  \(selectedItem)")
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeGestureRecognizer?.direction = .Down
        view.addGestureRecognizer(swipeGestureRecognizer!)
        
        view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.topItem?.title = "⌘v"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveDataButtonPressed")

        if sharedDefaults?.objectForKey(defaultskey) != nil {
            data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
            colors = sharedDefaults?.objectForKey(defaultColors) as! [String:String]
            
            var tempDict = [String:String]()
            for (key, value) in colors {
                for dict in data {
                    if dict[key] != nil {
                        tempDict[key] = value
                    }
                }
            }
            
            sharedDefaults?.setValue(tempDict, forKey:defaultColors)
            sharedDefaults?.synchronize()
        }
        else {
            data.append(["Next Keyboard":"Next Keyboard"])
            colors["Next Keyboard"] = "0"
            sharedDefaults?.setObject(data, forKey: defaultskey)
            sharedDefaults?.setObject(colors, forKey: defaultColors)
            sharedDefaults?.synchronize()
        }
        
        count = data.count
        
        var layout = ReorderableCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView = UICollectionView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, view.frame.width, 260), collectionViewLayout: layout)
        collectionView?.contentInset = UIEdgeInsetsMake(1, 1, 1, 0)
        collectionView!.backgroundColor = UIColor.lightGrayColor()
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        view.addSubview(collectionView!)
        
        defaultTextLabel = UILabel()
        instructionalLabel = UILabel()
        
        for label in [defaultTextLabel, instructionalLabel] {
            label?.numberOfLines = 0
            label?.textAlignment = .Center
            label?.preferredMaxLayoutWidth = view.frame.width
            label?.lineBreakMode = .ByWordWrapping
            label?.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        defaultTextLabel?.textColor = UIColor.darkGrayColor()
        defaultTextLabel?.text = "Add keys by pressing the + Button in the upper right corner."
        defaultTextLabel?.hidden = self.count > 1
        view.addSubview(defaultTextLabel!)
        
        instructionalLabel?.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it."
        instructionalLabel?.textColor = UIColor.darkGrayColor()
        view.addSubview(instructionalLabel!)
        
        textFieldOne = UITextField()
        textFieldTwo = UITextField()
        textFieldOne?.frame = CGRectMake(20, 430, view.frame.width - 40, 44)
        textFieldTwo?.frame = CGRectMake(20, CGRectGetMaxY(collectionView!.frame) + 10 + 44 + 10, view.frame.width - 40, 44)
        textFieldTwo?.alpha = 0.0
        textFieldTwo?.hidden = true
        
        for textField in [textFieldOne, textFieldTwo] {
            textField?.delegate = self
            textField?.autocorrectionType = .No
            textField?.borderStyle = .Line
            textField?.userInteractionEnabled = false
            textField?.textAlignment = .Center
            textField?.layer.borderColor = UIColor.lightGrayColor().CGColor
            textField?.layer.borderWidth = 1.0
            view.addSubview(textField!)
        }

        view.addConstraint(NSLayoutConstraint(item: defaultTextLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: defaultTextLabel!, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 120))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[instructionalLabel]-100-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["instructionalLabel":instructionalLabel!]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[instructionalLabel]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["instructionalLabel":instructionalLabel!]))
        
        editKeysButton = UIButton()
        editKeysButton?.setTitle("Edit Keys", forState: .Normal)
        editKeysButton?.setTitleColor(view.tintColor, forState: .Normal)
        editKeysButton?.addTarget(self, action: "editButtonPressed", forControlEvents: .TouchUpInside)
        editKeysButton?.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(editKeysButton!)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[edit]-40-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["edit":editKeysButton!]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[edit]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["edit":editKeysButton!]))
        
        checkKeyCount()
    }
    
    func checkKeyCount () {
        if data.count == 1 {
            
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
            navigationItem.leftBarButtonItem?.enabled = false
            
            defaultTextLabel?.hidden = false
            defaultTextLabel?.alpha = 1.0
            
            editKeysButton?.hidden = true
            editKeysButton?.alpha = 0.0
            
            textFieldOne?.hidden = true
            textFieldOne?.alpha = 0.0
            
            instructionalLabel?.hidden = true
            instructionalLabel?.alpha = 0.0
            
            self.collectionView?.backgroundColor = UIColor.clearColor()
            collectionView?.alpha = 0.0
        }
        else if data.count > 1 {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.enabled = true
                
                self.defaultTextLabel?.hidden = true
                self.defaultTextLabel?.alpha = 0.0
                
                self.editKeysButton?.hidden = false
                self.editKeysButton?.alpha = 1.0
                
                self.textFieldOne?.hidden = false
                self.textFieldOne?.alpha = 1.0
                
                self.instructionalLabel?.hidden = false
                self.instructionalLabel?.alpha = 1.0
                
                self.collectionView?.backgroundColor = UIColor.lightGrayColor()
                self.collectionView?.alpha = 1.0
            })
        }
    }
    
    func editButtonPressed () {
        editKeysButton!.selected = !editKeysButton!.selected
        if editKeysButton!.selected {
            UIView.animateWithDuration(0.5, animations: {
                self.textFieldOne!.alpha = 0
                self.textFieldOne!.frame = CGRectMake(20, CGRectGetMaxY(self.collectionView!.frame) + 10, self.view.frame.width - 40, 44)
                self.instructionalLabel?.alpha = 0
                self.editKeysButton!.alpha = 0
                }) { (value) in
                    self.instructionalLabel?.text = "Touch a key to edit it."
                    self.editKeysButton?.setTitle("Done", forState: .Normal)
                    
                    UIView.animateWithDuration(0.5, animations: {
                            self.instructionalLabel!.alpha = 1.0
                            self.editKeysButton!.alpha = 1.0
                        }, completion: { (value) in })
            }
        }
        else {
            self.textFieldTwo!.alpha = 0
            
            UIView.animateWithDuration(0.5, animations: {
                    self.textFieldOne!.frame = CGRectMake(20, 430, self.view.frame.width - 40, 44)
                    self.instructionalLabel?.alpha = 0
                    self.editKeysButton!.alpha = 0
                }) { (value) in
                    self.instructionalLabel?.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it."
                    self.editKeysButton?.setTitle("Edit keys", forState: .Normal)
                    self.textFieldOne?.placeholder = ""
                    
                    UIView.animateWithDuration(0.5, animations: {
                        self.textFieldOne!.alpha = 1.0
                        self.instructionalLabel!.alpha = 1.0
                        self.editKeysButton!.alpha = 1.0
                        }, completion: { (value) in
                        self.collectionView?.reloadData()
                    })
            }
        }
    }
    
    func addNewItem () {
        if data.count < 8 {
            count++
            data.insert(["Add a Title":"Press Edit Keys to add data."], atIndex: 0)
            collectionView?.reloadData()
            checkKeyCount()
        }
    }
    
    func saveDataButtonPressed () {
        RKDropdownAlert.title("Saved", backgroundColor: UIColor(red: 48/255, green: 160/255, blue: 61/255, alpha: 1.0), textColor: UIColor.whiteColor(), time: 1)
        saveData()
    }
    
    func saveData () {
        self.sharedDefaults?.setValue(data, forKey:defaultskey)
        self.sharedDefaults?.setValue(colors, forKey:defaultColors)
        self.sharedDefaults?.synchronize()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonCell", forIndexPath: indexPath) as! PreviewCell

        cell.layer.cornerRadius = 3
        
        let dict = data[indexPath.item]
        
        for (key, value) in dict {
            cell.setLabelText(key)
            let colorIndex = colors[key]
            
            if key == "Next Keyboard" || colors[key] == nil {
                cell.backgroundColor = UIColor.darkGrayColor()
                cell.keyTextLabel?.textColor = UIColor.whiteColor()
            }
            else {
                cell.backgroundColor = colorRef[colorIndex!.toInt()!] as UIColor!
            }
        }
        
        if data.count > 1 {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                cell.hidden = false
                cell.alpha = 1.0
            })
        }
        else {
            cell.hidden = true
            cell.alpha = 0.0
        }

        if indexPath.item == selectedItem {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(-65, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSizeZero
        switch data.count {
        case 1:
            size = CGSizeMake(collectionView.frame.width - 2, collectionView.frame.height - 2)
        case 2:
            size = CGSizeMake((collectionView.frame.width/2) - 2, collectionView.frame.height - 2)
        case 3:
            size = CGSizeMake(collectionView.frame.width - 2, collectionView.frame.height/3 - 2)
        case 4:
            size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/2) - 2)
        case 5:
            if indexPath.item < 2 {
                size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/2) - 2)
            }
            else {
                size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/3 - 2)
            }
        case 6:
            size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/3) - 2)
        case 7:
            if indexPath.item < 3 {
                size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/3 - 2)
            }
            else {
                size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/4 - 2)
            }
        case 8:
            size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/4 - 2)
        default:
            println("2")
        }
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        var keyBeingMoved = self.data[fromIndexPath.item]
        self.data.removeAtIndex(fromIndexPath.item)
        self.data.insert(keyBeingMoved, atIndex: toIndexPath.item)
        var passingArray = data as [[String:String]]
        passingArray.removeLast()
        self.sharedDefaults?.setValue(passingArray, forKey:self.defaultskey)
        self.sharedDefaults?.synchronize()
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.item == 0 {
            return true
        }
        if indexPath.item < (self.data.count-1) {
            return true
        }
        return false
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item < (self.data.count - 1) {
            return true
        }
        return false
    }
}

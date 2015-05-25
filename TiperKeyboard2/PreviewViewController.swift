//  PreviewViewController.swift
//  TiperKeyboard2
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource, UITextFieldDelegate, UIScrollViewDelegate{
    
    var scrollView = UIScrollView()
    var containerView = UIView()
    var expandedVConstraints = []
    var expandedHConstraints = []
    var compactVConstraints = []
    var collectionView : UICollectionView?
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var tempData = [String:String]()
    var count = 0
    var selectedItem = 0
    var lastContentOffSet : CGFloat = 0.0
    var colors = [String:String]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    let colorRef = ColorPalette.colorRef
    var textFieldOne = UITextField()
    var textFieldTwo = UITextField()
    var textFieldThree = UITextField()
    var defaultTextLabel = UILabel()
    var instructionalLabel = UILabel()
    var editKeysButton = UIButton()
    var deleteKeysButton = UIButton()
    var questionButton = UIButton()
    var colorPaletteView = ColorPaletteView()
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() == true {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func keyboardShown (notification : NSNotification) {
        if UIScreen.mainScreen().bounds.height < 600 {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height + keyboardSize.height)
                scrollView.setContentOffset(CGPointMake(0.0, textFieldTwo.frame.origin.y - keyboardSize.height), animated: true)
            }
        }
    }
    
    func keyboardHidden (notif : NSNotification) {
        if editKeysButton.selected == false  && UIScreen.mainScreen().bounds.height < 600 {
            scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        }
        else {
            scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height + 44)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for textField in [textFieldOne, textFieldTwo] {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
            }
        }
    }
    
    func clearText () {
        for textField in [textFieldOne, textFieldThree, textFieldThree] {
            textField.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)

        view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.title = "Short Key"
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
            data.append(["Next Keyboard":"This key changes keyboards"])
            colors["Next Keyboard"] = "0"
            saveData()
        }
        count = data.count
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        scrollView.delegate = self
        view.addSubview(scrollView)
        containerView.frame = scrollView.bounds
        scrollView.addSubview(containerView)
        
        var layout = ReorderableCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, view.frame.width, 260), collectionViewLayout: layout)
        collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.contentSize = CGSizeMake(view.frame.width, 260)
        containerView.addSubview(collectionView!)
        
        defaultTextLabel.text = "Add keys by pressing the + Button in the upper right corner."
        defaultTextLabel.hidden = count > 1
        instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
        
        for label in [defaultTextLabel, instructionalLabel] {
            label.numberOfLines = 0
            label.textColor = UIColor.darkGrayColor()
            label.textAlignment = .Center
            label.preferredMaxLayoutWidth = view.frame.width
            label.lineBreakMode = .ByWordWrapping
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            containerView.addSubview(label)
        }
        
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem:containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 120))
        
        for textField in [textFieldOne, textFieldTwo, textFieldThree] {
            textField.backgroundColor = UIColor.lightGrayColor()
            textField.setTranslatesAutoresizingMaskIntoConstraints(false)
            textField.delegate = self
            textField.autocorrectionType = .No
            textField.borderStyle = .Line
            textField.userInteractionEnabled = false
            textField.textAlignment = .Center
            textField.layer.borderColor = UIColor.lightGrayColor().CGColor
            textField.layer.borderWidth = 1.0
            textField.returnKeyType = UIReturnKeyType.Done
            containerView.addSubview(textField)
        }
        
        colorPaletteView.setTranslatesAutoresizingMaskIntoConstraints(false)
        for view in [textFieldTwo, textFieldOne, colorPaletteView, deleteKeysButton] {
            view.alpha = 0.0
            view.hidden = true
        }

        colorPaletteView.updateColorCallback = { (index) in
            var dict = self.data[self.selectedItem]
            self.colors[dict.keys.first!] = "\(index)"
            self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: self.selectedItem, inSection: 0)])
            self.saveData()
        }
        containerView.addSubview(colorPaletteView)
        
        for button in [editKeysButton, deleteKeysButton, questionButton] {
            button.setTitleColor(view.tintColor, forState: .Normal)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            containerView.addSubview(button)
        }
        
        editKeysButton.setTitle("Edit Keys", forState: .Normal)
        editKeysButton.addTarget(self, action: "editButtonPressed", forControlEvents: .TouchUpInside)
        deleteKeysButton.setTitle("Delete", forState: .Normal)
        deleteKeysButton.addTarget(self, action: "deleteButtonPressed", forControlEvents: .TouchUpInside)
        questionButton.setTitle("?", forState: .Normal)
        questionButton.titleLabel?.font = UIFont.systemFontOfSize(20)
        questionButton.addTarget(self, action: "questionButtonPressed", forControlEvents: .TouchUpInside)
        
        var metrics = ["cvH":UIScreen.mainScreen().bounds.height < 600 ? 200 : 260, "padding":UIScreen.mainScreen().bounds.height < 600 ? 10 : 30]
        var views = ["tfThree":textFieldThree,"tfTwo":textFieldTwo, "tfOne":textFieldOne, "edit":editKeysButton, "cv":collectionView!, "instrLab":instructionalLabel, "colorP":colorPaletteView, "delete":deleteKeysButton, "question":questionButton]

        expandedVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cv(260)]-[tfOne(44)]-[tfTwo(44)]-[colorP]-[instrLab]-[edit]-[question]", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        expandedHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[question(100)]-(>=1)-[delete(100)]-|", options: .AlignAllCenterY, metrics: metrics, views: views)
        compactVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cv(260)]-padding-[tfThree(44)]-padding-[instrLab]-padding-[edit]-padding-[question]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: metrics, views:views)
        containerView.addConstraints(compactVConstraints as! [NSLayoutConstraint])
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[instrLab]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views:views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cv]|", options: NSLayoutFormatOptions(0), metrics: nil, views:views))
        for myView in [textFieldThree, textFieldTwo, textFieldOne, editKeysButton, colorPaletteView] {
            containerView.addConstraint(NSLayoutConstraint(item: myView, attribute: .Left, relatedBy: .Equal, toItem: instructionalLabel, attribute: .Left, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: myView, attribute: .Right, relatedBy: .Equal, toItem: instructionalLabel, attribute: .Right, multiplier: 1.0, constant: 0))
        }
        
        checkKeyCount()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        colorPaletteView.alpha = 0.0
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        clearText()
        if data.count == 8 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
         saveData()
    }
    
    func questionButtonPressed () {
        let infoView = InformationViewController()
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    func deleteButtonPressed () {
        if data.count > 2 {
            data.removeAtIndex(selectedItem)
            saveData()
            collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: selectedItem, inSection: 0)])
            if data.count == 1 {
                UIView.animateWithDuration(1.0, animations: {
                    self.deleteKeysButton.alpha = 0.0
                    self.deleteKeysButton.hidden = true
                })
            }
        }
        navigationItem.rightBarButtonItem?.tintColor = view.tintColor
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedItem = indexPath.item
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? PreviewCell
        var originalColor = cell?.contentView.backgroundColor
        
        if editKeysButton.selected == false {
            UIView.animateWithDuration(0.2, animations: {
                cell?.contentView.backgroundColor = UIColor.darkGrayColor()
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.2, animations: {
                        cell?.contentView.backgroundColor = originalColor
                    })
            })
            var keyDict = data[indexPath.item]
            for (key, value) in keyDict {
                textFieldThree.text = value
            }
        }
        else {
            if indexPath.item == (data.count - 1) {
                return
            }
            instructionalLabel.alpha = 0.0
            containerView.removeConstraints(compactVConstraints as! [NSLayoutConstraint])
            containerView.addConstraints(expandedVConstraints as! [NSLayoutConstraint])
            containerView.addConstraints(expandedHConstraints as! [NSLayoutConstraint])
            textFieldTwo.placeholder = "What will this key type when pressed?"
            textFieldOne.placeholder = "What is the name of this key?"
            instructionalLabel.text = "Press + to add keys.  Press Save to bind.  Press delete to remove a key."
            if UIScreen.mainScreen().bounds.height < 600 {
                scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height + 44)
            }
            else {
                scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
            }

            UIView.animateWithDuration(0.5, animations: {
                if self.data.count > 2 {
                    self.deleteKeysButton.alpha = 1.0
                    self.deleteKeysButton.hidden = false
                }
                
                self.colorPaletteView.alpha = 0.0
                self.colorPaletteView.hidden = true

                for textField in [self.textFieldOne, self.textFieldTwo] {
                    textField.alpha = 1.0
                    textField.hidden = false
                    textField.userInteractionEnabled = true
                    textField.text = ""
                }
                self.textFieldThree.alpha = 0.0
                self.textFieldThree.hidden = true
                self.instructionalLabel.alpha = 1.0

            }, completion: { (value) in
                self.collectionView!.reloadData()
            })
        }
    }
    
    func textChanged (notification:NSNotification) {
        if self.navigationController?.topViewController == self {
            colorPaletteView.alpha = 1.0
            colorPaletteView.hidden = false
            tempData = [String:String]()
            let textField = notification.object as! UITextField
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            tempData[textFieldOne.text] = textFieldTwo.text
            data.insert(tempData, atIndex: selectedItem)
            data.removeAtIndex(selectedItem + 1)
            collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedItem, inSection: 0)])
        }
    }
    
    func checkKeyCount () {
        if data.count == 1 {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
            navigationItem.leftBarButtonItem?.enabled = false
            
            defaultTextLabel.hidden = false
            defaultTextLabel.alpha = 1.0
            
            for view in [editKeysButton, textFieldThree, instructionalLabel, collectionView!, questionButton] {
                view.alpha = 0.0
                view.hidden = true
            }
            
            collectionView?.backgroundColor = UIColor.clearColor()
        }
        else if data.count > 1 {
            UIView.animateWithDuration(1.0, animations: {
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.enabled = true
                
                self.defaultTextLabel.hidden = true
                self.defaultTextLabel.alpha = 0.0
                
                for view in [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!, self.questionButton] {
                    view.alpha = 1.0
                    view.hidden = false
                }
            })
        }
    }
    
    func editButtonPressed () {
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        clearText()
        tempData.removeAll(keepCapacity: false)
        editKeysButton.selected = !editKeysButton.selected
        if editKeysButton.selected {
            UIView.animateWithDuration(0.5, animations: {
                for view in [self.colorPaletteView, self.textFieldOne, self.textFieldTwo, self.textFieldThree, self.editKeysButton, self.instructionalLabel, self.questionButton] {
                    view.alpha = 0.0
                }
                    }) { (value) in
                        self.instructionalLabel.text = "Touch a key to edit it."
                        self.editKeysButton.setTitle("Done", forState: .Normal)
                    
                    UIView.animateWithDuration(0.5, animations: {
                            self.instructionalLabel.alpha = 1.0
                            self.editKeysButton.alpha = 1.0
                            self.questionButton.alpha = 1.0
                        }, completion: { (value) in })
            }
        }
        else {
            scrollView.setContentOffset(CGPointMake(0.0, -(navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height)), animated: true)
            for view in [colorPaletteView, deleteKeysButton, textFieldOne, textFieldTwo, editKeysButton, questionButton, instructionalLabel] {
                view.alpha = 0.0
            }
            containerView.removeConstraints(expandedVConstraints as! [NSLayoutConstraint])
            containerView.removeConstraints(expandedHConstraints as! [NSLayoutConstraint])
            containerView.addConstraints(compactVConstraints as! [NSLayoutConstraint])
            instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
            editKeysButton.setTitle("Edit keys", forState: .Normal)
            collectionView?.reloadData()
            UIView.animateWithDuration(0.4, animations: {
                for view in [self.textFieldThree, self.editKeysButton, self.questionButton, self.instructionalLabel] {
                    view.alpha = 1.0
                }
                self.textFieldThree.hidden = false
                self.colorPaletteView.alpha = 0.0
                self.colorPaletteView.hidden = true
            }, completion: { (value) in })
        }
    }
    
    func addNewItem () {
        if data.count < 8 {
            count++
            data.insert(["Add a Title":"Press Edit Keys to add data."], atIndex: 0)
            checkKeyCount()
            collectionView?.reloadData()
        }
    }
    
    func saveDataButtonPressed () {
        RKDropdownAlert.title("Saved", backgroundColor: UIColor(red: 48/255, green: 160/255, blue: 61/255, alpha: 1.0), textColor: UIColor.whiteColor(), time: 1)
        saveData()
    }
    
    func saveData () {
        sharedDefaults?.setValue(data, forKey:defaultskey)
        sharedDefaults?.setValue(colors, forKey:defaultColors)
        sharedDefaults?.synchronize()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonCell", forIndexPath: indexPath) as! PreviewCell
        cell.layer.borderColor = UIColor.clearColor().CGColor
        let dict = data[indexPath.item]
        
        if indexPath.item == selectedItem && editKeysButton.selected == true {
            cell.layer.borderColor = view.tintColor.CGColor
            cell.layer.borderWidth = 5
        }
        
        for (key, value) in dict {
            cell.setLabelText(key)
            let colorIndex = colors[key]
            cell.circleView?.backgroundColor = colors[key] == nil ? UIColor.clearColor() : colorRef[colorIndex!.toInt()!] as UIColor!
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
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
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
            size = CGSizeMake(collectionView.frame.width/2 - 3, collectionView.frame.height/4 - 3)
        default:
            println("2")
        }
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let keyBeingMoved = data[fromIndexPath.item]
        data.removeAtIndex(fromIndexPath.item)
        data.insert(keyBeingMoved, atIndex: toIndexPath.item)
        saveData()
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.item < (data.count-1) {
            return true
        }
        return false
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item < (data.count - 1) {
            return true
        }
        return false
    }
}

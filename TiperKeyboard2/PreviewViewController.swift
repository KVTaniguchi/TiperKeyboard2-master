//  PreviewViewController.swift
//  TiperKeyboard2
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource, UITextFieldDelegate, UIScrollViewDelegate{
    
    var scrollView = UIScrollView()
    var containerView = UIView()
    var expandedVConstraints = [], expandedHConstraints = [], compactVConstraints = []
    var collectionView : UICollectionView?
    var data = [[String:String]]()
    var tempData = [String:String]()
    var count = 0, selectedItem = 0
    var lastContentOffSet : CGFloat = 0.0
    var colors = [String:String]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var textFieldOne = UITextField(), textFieldTwo = UITextField(), textFieldThree = UITextField()
    var defaultTextLabel = UILabel(), instructionalLabel = UILabel()
    var editKeysButton = UIButton(), deleteKeysButton = UIButton(), questionButton = UIButton()
    var colorPaletteView = ColorPaletteView()
    
    let colorRef = ColorPalette.colorRef
    let defaultskey = "tiper2Keyboard", defaultColors = "tiper2Colors"
    let sizeBucket = SizeBucket()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)

        view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.topItem?.title = "Short Key"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveDataButtonPressed")
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if sharedDefaults?.objectForKey(defaultskey) != nil {
            data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
            colors = sharedDefaults?.objectForKey(defaultColors) as! [String:String]
            
            var tempDict = [String:String]()
            for (key, value) in colors {
                data.map { dict -> [String:String] in
                    if dict[key] != nil {
                        tempDict[key] = value
                    }
                    return dict
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
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.contentSize = CGSizeMake(view.frame.width - 30, 260)
        containerView.addSubview(collectionView!)
        
        defaultTextLabel.text = "Add keys by pressing the + Button in the upper right corner."
        defaultTextLabel.hidden = count > 1
        instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
        
        [defaultTextLabel, instructionalLabel].map { label -> UILabel in
            label.numberOfLines = 0
            label.textColor = UIColor.darkGrayColor()
            label.textAlignment = .Center
            label.preferredMaxLayoutWidth = self.view.frame.width
            label.lineBreakMode = .ByWordWrapping
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.containerView.addSubview(label)
            return label
        }
        
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem:containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 120))
        
        [textFieldOne, textFieldTwo, textFieldThree].map { textField -> UITextField in
            textField.backgroundColor = UIColor.darkGrayColor()
            textField.textColor = UIColor.whiteColor()
            textField.setTranslatesAutoresizingMaskIntoConstraints(false)
            textField.delegate = self
            textField.autocorrectionType = .No
            textField.borderStyle = UITextBorderStyle.None
            textField.userInteractionEnabled = false
            textField.textAlignment = .Center
            textField.returnKeyType = UIReturnKeyType.Done
            self.containerView.addSubview(textField)
            return textField
        }
        
        colorPaletteView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        [textFieldTwo, textFieldOne, colorPaletteView, deleteKeysButton].map{$0.alpha = 0}
        [textFieldTwo, textFieldOne, colorPaletteView, deleteKeysButton].map{$0.hidden = true}

        colorPaletteView.updateColorCallback = { (index) in
            var dict = self.data[self.selectedItem]
            self.colors[dict.keys.first!] = "\(index)"
            self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: self.selectedItem, inSection: 0)])
            self.saveData()
        }
        containerView.addSubview(colorPaletteView)
        
        [editKeysButton, deleteKeysButton, questionButton].map { button -> UIButton in
            button.layer.cornerRadius = 5
            button.setTitleColor(self.view.tintColor, forState: .Normal)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.containerView.addSubview(button)
            return button
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
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[cv]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views:views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[edit(160)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        containerView.addConstraint(NSLayoutConstraint(item: editKeysButton, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        [textFieldThree, textFieldTwo, textFieldOne, colorPaletteView].map{self.containerView.addConstraint(NSLayoutConstraint(item: $0, attribute: .Left, relatedBy: .Equal, toItem: self.instructionalLabel, attribute: .Left, multiplier: 1.0, constant: 0))}
        [textFieldThree, textFieldTwo, textFieldOne, colorPaletteView].map{self.containerView.addConstraint(NSLayoutConstraint(item: $0, attribute: .Right, relatedBy: .Equal, toItem: self.instructionalLabel, attribute: .Right, multiplier: 1.0, constant: 0))}
        
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
    
    // MARK Notifications
    func keyboardHidden (notif : NSNotification) {
        if editKeysButton.selected == false  && UIScreen.mainScreen().bounds.height < 600 {
            scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        }
        else {
            scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height + 44)
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
            
            [editKeysButton, textFieldThree, instructionalLabel, collectionView!, questionButton].map{$0.alpha = 0.0}
            [editKeysButton, textFieldThree, instructionalLabel, collectionView!, questionButton].map{$0.hidden = true}
            
            collectionView?.backgroundColor = UIColor.clearColor()
        }
        else if data.count > 1 {
            UIView.animateWithDuration(1.0, animations: {
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.enabled = true
                
                self.defaultTextLabel.hidden = true
                self.defaultTextLabel.alpha = 0.0
                
                [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!, self.questionButton].map{$0.alpha = 1.0}
                [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!, self.questionButton].map{$0.hidden = false}
            })
        }
    }
    
    // MARK Actions
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
    
    func editButtonPressed () {
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        clearText()
        tempData.removeAll(keepCapacity: false)
        editKeysButton.selected = !editKeysButton.selected
        if editKeysButton.selected {
            UIView.animateWithDuration(0.5, animations: {
                [self.colorPaletteView, self.textFieldOne, self.textFieldTwo, self.textFieldThree, self.editKeysButton, self.instructionalLabel, self.questionButton].map{$0.alpha = 0.0}
                }) { (value) in
                    self.instructionalLabel.text = "Touch a key to edit it"
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
            [colorPaletteView, deleteKeysButton, textFieldOne, textFieldTwo, editKeysButton, questionButton, instructionalLabel].map{$0.alpha = 0.0}
            
            containerView.removeConstraints(expandedVConstraints as! [NSLayoutConstraint])
            containerView.removeConstraints(expandedHConstraints as! [NSLayoutConstraint])
            containerView.addConstraints(compactVConstraints as! [NSLayoutConstraint])
            instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
            editKeysButton.setTitle("Edit keys", forState: .Normal)
            collectionView?.reloadData()
            UIView.animateWithDuration(0.4, animations: {
                [self.textFieldThree, self.editKeysButton, self.questionButton, self.instructionalLabel].map {$0.alpha = 1.0}
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
    
    // MARK Collectionview methods
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
            textFieldOne.placeholder = "What is the name of this key?"
            textFieldOne.attributedPlaceholder = NSAttributedString(string: "What is the name of this key?", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont.systemFontOfSize(14)])
            textFieldTwo.attributedPlaceholder = NSAttributedString(string: "What will this key type when pressed?", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont.systemFontOfSize(14)])
            
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
                
                [self.textFieldOne, self.textFieldTwo].map { textField -> UITextField in
                    textField.alpha = 1.0
                    textField.hidden = false
                    textField.userInteractionEnabled = true
                    textField.text = ""
                    return textField
                }
                
                self.textFieldThree.alpha = 0.0
                self.textFieldThree.hidden = true
                self.instructionalLabel.alpha = 1.0
                
                }, completion: { (value) in
                    self.collectionView!.reloadData()
            })
        }
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
        return sizeBucket.getSizes(collectionView.frame, count: data.count, indexPath: indexPath)
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
    
    
    // MARK Scroll view delegate methods
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for textField in [textFieldOne, textFieldTwo] {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
            }
        }
    }
    
    // MARK Convenience
    func clearText () {
        [textFieldOne, textFieldThree, textFieldThree].map{$0.text = ""}
    }
    
    func saveData () {
        sharedDefaults?.setValue(data, forKey:defaultskey)
        sharedDefaults?.setValue(colors, forKey:defaultColors)
        sharedDefaults?.synchronize()
    }
    
    // MARK Textfield delegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() == true {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK keyboard notifications
    
    func keyboardShown (notification : NSNotification) {
        if UIScreen.mainScreen().bounds.height < 600 {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height + keyboardSize.height)
                scrollView.setContentOffset(CGPointMake(0.0, textFieldTwo.frame.origin.y - keyboardSize.height), animated: true)
            }
        }
    }
}

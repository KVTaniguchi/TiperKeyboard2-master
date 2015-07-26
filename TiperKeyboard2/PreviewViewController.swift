//  PreviewViewController.swift
//  TiperKeyboard2
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var scrollView = UIScrollView()
    var containerView = UIView()
    var expandedVConstraints = [], expandedHConstraints = [], compactVConstraints = []
    var collectionView : UICollectionView?
    var pagingIndicator  = UIPageControl()
    var data = [[String:String]]()
    var allData = [String  : [[String:String]]]()
    var allColors = [[String:String]]()
    var count = 0, currentKBIndex = 0
    var lastContentOffSet : CGFloat = 0.0
    var colors = [String:String]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var textFieldOne = UITextField(), textFieldTwo = UITextField(), textFieldThree = UITextField()
    var defaultTextLabel = UILabel(), instructionalLabel = UILabel()
    var editKeysButton = UIButton(), deleteKeysButton = UIButton(), questionButton = UIButton()
    var colorPaletteView = ColorPaletteView()
    let colorRef = ColorPalette.colorRef
    let defaultskey = "tiper2Keyboard", defaultColors = "tiper2Colors", defaultsAllKBKey = "tiper2KeyboardAllKB", defaultsAllColorsKey = "tiper2KBAllColors"
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

        if sharedDefaults?.objectForKey(defaultsAllKBKey) != nil {
            allData = sharedDefaults?.objectForKey(defaultsAllKBKey) as! [String : [[String:String]]]!
            allColors = sharedDefaults?.objectForKey(defaultsAllColorsKey) as! [[String:String]]
            count = allData["0"]!.count
        }
        else {
            if sharedDefaults?.objectForKey(defaultskey) != nil {
              // For legacy users, add the extra keyboards for free
                data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
                colors = sharedDefaults?.objectForKey(defaultColors) as! [String:String]
                count = data.count
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
                colors["Next Keyboard"] = "0"
            }
            
            allData["0"] = [["Next Keyboard":"This key changes keyboards"]]
            allColors.append(colors)
            saveData()
        }
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        scrollView.delegate = self
        view.addSubview(scrollView)
        containerView.frame = scrollView.bounds
        scrollView.addSubview(containerView)
        
        var layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        collectionView!.registerClass(ContainedKBCollectionViewCell.self, forCellWithReuseIdentifier: "allKBCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView?.pagingEnabled = true
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

        colorPaletteView.updateColorCallback = { index in
            self.currentKBCollectionView().updateCellCircleViewWithColor(index)
            var currentColors = self.allColors[self.currentKBIndex]
            currentColors[self.textFieldOne.text!] = "\(index)"
            self.allColors[self.currentKBIndex] = currentColors
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
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cv]|", options: NSLayoutFormatOptions(0), metrics: nil, views:views))
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
//        if data.count == 8 {
//            navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
//            navigationItem.rightBarButtonItem?.enabled = false
//        }
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
            let textField = notification.object as! UITextField
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            updateAndSaveData()
            if textField == textFieldOne {
                currentKBCollectionView().updateCellTextWithText(textField.text)
            }
        }
    }
    
    func checkKeyCount () {
        if count == 0 {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
            navigationItem.leftBarButtonItem?.enabled = false
            
            defaultTextLabel.hidden = false
            defaultTextLabel.alpha = 1.0
            collectionView?.alpha = 0.0
            [editKeysButton, textFieldThree, instructionalLabel, questionButton].map{$0.alpha = 0.0}
            [editKeysButton, textFieldThree, instructionalLabel, questionButton].map{$0.hidden = true}
        }
        else {
            UIView.animateWithDuration(1.0, animations: {
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.enabled = true
                
                self.defaultTextLabel.hidden = true
                self.collectionView?.alpha = 1.0
                [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.questionButton].map{$0.alpha = 1.0}
                [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.questionButton].map{$0.hidden = false}
            })
        }
    }
    
    // MARK Actions
    func questionButtonPressed () {
        let infoView = InformationViewController()
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    func deleteButtonPressed () {
//        if data.count > 2 {
//            data.removeAtIndex(currentKBCollectionView().selectedItem)
//            saveData()
//            collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: currentKBCollectionView().selectedItem, inSection: 0)])
//            if data.count == 1 {
//                UIView.animateWithDuration(1.0, animations: {
//                    self.deleteKeysButton.alpha = 0.0
//                    self.deleteKeysButton.hidden = true
//                })
//            }
//        }
        
        print(currentKBCollectionView().selectedItem)
        
        let currentPath = collectionView?.indexPathsForVisibleItems().first as! NSIndexPath
        if allData["\(currentPath.item)"]!.count > 1 {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
            
            currentKBCollectionView().keyData.removeAtIndex(currentKBCollectionView().selectedItem)
            currentKBCollectionView().collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: currentKBCollectionView().selectedItem, inSection: 0)])
            if data.count == 1 {
                UIView.animateWithDuration(1.0, animations: {
                    self.deleteKeysButton.alpha = 0.0
                    self.deleteKeysButton.hidden = true
                })
            }
            
            saveData()
        }
    }
    
    func editButtonPressed () {
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
        editKeysButton.selected = !editKeysButton.selected
        currentKBCollectionView().editingEnabled = true
        
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
            updateAndSaveData()
            
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
        
        clearText()
    }
    
    func addNewItem () {
        if currentKBCollectionView().keyData.count < 8 {
            currentKBCollectionView().addNewKey()
            count = currentKBCollectionView().keyData.count
            checkKeyCount()
        }
        else if allData.count < 5 {
            var mutatingData = allData
            for (key, value) in allData {
                if key.toInt()! > currentKBIndex {
                    mutatingData["\(key.toInt()! + 1)"] = value
                }
            }
            allData = mutatingData
            allData["\(currentKBIndex + 1)"] = [["Next Keyboard":"This key changes keyboards"]]
            allColors.append(["Next Keyboard":"0"])
            collectionView?.reloadData()
            collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: currentKBIndex + 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
    
    func saveDataButtonPressed () {
        RKDropdownAlert.title("Saved", backgroundColor: UIColor(red: 48/255, green: 160/255, blue: 61/255, alpha: 1.0), textColor: UIColor.whiteColor(), time: 1)
        saveData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("allKBCell", forIndexPath: indexPath) as! ContainedKBCollectionViewCell
        let kbData = allData["\(indexPath.item)"]
        let colors = allColors[indexPath.item]
        data = kbData!
        cell.configureKBCellWithData(kbData!, isEditing: editKeysButton.selected, keyColors: colors)
        cell.animateCallbackWithData = { amount in
            self.updateAndSaveData()
            
            if self.editKeysButton.selected == true {
                self.instructionalLabel.alpha = 0.0
                self.containerView.removeConstraints(self.compactVConstraints as! [NSLayoutConstraint])
                self.containerView.addConstraints(self.expandedVConstraints as! [NSLayoutConstraint])
                self.containerView.addConstraints(self.expandedHConstraints as! [NSLayoutConstraint])
                self.textFieldOne.placeholder = "What is the name of this key?"
                self.textFieldOne.attributedPlaceholder = NSAttributedString(string: "What is the name of this key?", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont.systemFontOfSize(14)])
                self.textFieldTwo.attributedPlaceholder = NSAttributedString(string: "What will this key type when pressed?", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:UIFont.systemFontOfSize(14)])
                
                self.instructionalLabel.text = "Press + to add keys.  Press Save to bind.  Press delete to remove a key."
                if UIScreen.mainScreen().bounds.height < 600 {
                    self.scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height + 44)
                }
                else {
                    self.scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height))
                }
                
                UIView.animateWithDuration(0.5, animations: {
                    if amount > 2 {
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
                })
            }
            
        }
        
        cell.updateAllDataWithData = { data in
            self.allData["\(indexPath.item)"] = data
            self.saveData()
        }
        
        cell.updateTextField = { text in
            self.textFieldThree.text = text
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allData.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width, 260)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        currentKBIndex = indexPath.item
        
//        if allData["\(indexPath.item)"]?.count < 8 || indexPath.item + 1 == allData.count {
//            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
//            navigationItem.rightBarButtonItem?.enabled = true
//        }
//        else {
//            navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
//            navigationItem.rightBarButtonItem?.enabled = false
//        }
    }
    
    // MARK Scroll view delegate methods
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for textField in [textFieldOne, textFieldTwo] {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        addNewItem()
    }
    
    // MARK Convenience
    func updateAndSaveData () {
        var currentData = allData["\(currentKBIndex)"]!
        currentData[currentKBCollectionView().selectedItem] = [textFieldOne.text:textFieldTwo.text]
        allData["\(currentKBIndex)"] = currentData
        currentKBCollectionView().keyData = currentData
        saveData()
    }
    
    func clearText () {
        [textFieldOne, textFieldThree, textFieldThree].map{$0.text = ""}
    }
    
    func saveData () {
        sharedDefaults?.setValue(allColors, forKey: defaultsAllColorsKey)
        sharedDefaults?.setValue(allData, forKey: defaultsAllKBKey)
        sharedDefaults?.synchronize()
    }
    
    func currentKBCollectionView () -> ContainedKBCollectionViewCell {
        return collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: currentKBIndex, inSection: 0)) as! ContainedKBCollectionViewCell
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

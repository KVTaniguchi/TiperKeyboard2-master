//  PreviewViewController.swift
//  TiperKeyboard2
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource, UITextFieldDelegate {
    
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
    var colors = [String:String]()
    var buttonArray = [UIButton]()
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
    var swipeGestureRecognizer : UISwipeGestureRecognizer?
    var colorPaletteView = ColorPaletteView()
    
    func keyboardShown (notification : NSNotification) {
        if UIScreen.mainScreen().bounds.height < 600 {
            // adjust insets
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                var aRect = view.frame
                aRect.size.height -= keyboardSize.height
                scrollView.scrollRectToVisible(textFieldTwo.frame, animated: true)
            }
        }
    }
    
    func keyboardHidden (notif : NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < 600 {
            // adjust insets
            let contentInsets = UIEdgeInsetsZero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.scrollRectToVisible(collectionView!.frame, animated: true)
        }
    }
    
    
//    - (void)keyboardWasShown:(NSNotification*)aNotification
//    {
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//    [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
//    }
//    }
//    
//    // Called when the UIKeyboardWillHideNotification is sent
//    - (void)keyboardWillBeHidden:(NSNotification*)aNotification
//    {
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)
        
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeGestureRecognizer?.direction = .Down
        view.addGestureRecognizer(swipeGestureRecognizer!)
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
            data.append(["Next Keyboard":"Next Keyboard"])
            colors["Next Keyboard"] = "0"
            sharedDefaults?.setObject(data, forKey: defaultskey)
            sharedDefaults?.setObject(colors, forKey: defaultColors)
            sharedDefaults?.synchronize()
        }
        count = data.count
        
        scrollView.frame = view.bounds
//        scrollView.contentSize = view.bounds.size
        view.addSubview(scrollView)
        
        containerView.frame = scrollView.bounds
        scrollView.addSubview(containerView)
        
        var layout = ReorderableCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView = UICollectionView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, view.frame.width, 260), collectionViewLayout: layout)
        collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.contentSize = CGSizeMake(view.frame.width, 260)
        containerView.addSubview(collectionView!)
        
        for label in [defaultTextLabel, instructionalLabel] {
            label.numberOfLines = 0
            label.textAlignment = .Center
            label.preferredMaxLayoutWidth = view.frame.width
            label.lineBreakMode = .ByWordWrapping
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        defaultTextLabel.textColor = UIColor.darkGrayColor()
        defaultTextLabel.text = "Add keys by pressing the + Button in the upper right corner."
        defaultTextLabel.hidden = self.count > 1
        containerView.addSubview(defaultTextLabel)
        
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem:containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: defaultTextLabel, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 120))
        
        instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
        instructionalLabel.textColor = UIColor.darkGrayColor()
        containerView.addSubview(instructionalLabel)
        
        for textField in [textFieldOne, textFieldTwo, textFieldThree] {
            textField.setTranslatesAutoresizingMaskIntoConstraints(false)
            textField.delegate = self
            textField.autocorrectionType = .No
            textField.borderStyle = .Line
            textField.userInteractionEnabled = false
            textField.textAlignment = .Center
            textField.layer.borderColor = UIColor.lightGrayColor().CGColor
            textField.layer.borderWidth = 1.0
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
        
        var metrics = ["cvH":UIScreen.mainScreen().bounds.height < 600 ? 200 : 260,"topMargin":(self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height)]
        var views = ["tfThree":textFieldThree,"tfTwo":textFieldTwo, "tfOne":textFieldOne, "edit":editKeysButton, "cv":collectionView!, "instrLab":instructionalLabel, "colorP":colorPaletteView, "delete":deleteKeysButton, "question":questionButton]

        expandedVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cv(260)]-[tfOne(44)]-[tfTwo(44)]-[colorP]-[instrLab]-[edit]-[question]", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        expandedHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[question(100)]-(>=1)-[delete(100)]-|", options: .AlignAllCenterY, metrics: metrics, views: views)
        compactVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cv(260)]-[tfThree(44)]-[instrLab]-[edit]-[question]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: metrics, views:views)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textFieldOne.text = ""
        textFieldTwo.text = ""
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
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedItem = indexPath.item
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? PreviewCell
        var originalColor = cell?.backgroundColor
        
        if editKeysButton.selected == false {
            UIView.animateWithDuration(0.2, animations: {
                cell?.backgroundColor = UIColor.darkGrayColor()
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.2, animations: {
                        cell?.backgroundColor = originalColor
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
            self.containerView.removeConstraints(self.compactVConstraints as! [NSLayoutConstraint])
            self.containerView.addConstraints(self.expandedVConstraints as! [NSLayoutConstraint])
            self.containerView.addConstraints(self.expandedHConstraints as! [NSLayoutConstraint])
            self.textFieldTwo.placeholder = "What will this key type when pressed?"
            self.textFieldOne.placeholder = "What is the name of this key?"
            self.instructionalLabel.text = "Press + to add keys.  Press Save to bind.  Press delete to remove a key."
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
    
    func swipeDown () {
        for textField in [textFieldOne, textFieldTwo] {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
            }
        }
    }
    
    func textChanged (notification:NSNotification) {
        self.colorPaletteView.alpha = 1.0
        self.colorPaletteView.hidden = false
        tempData = [String:String]()
        let textField = notification.object as! UITextField
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        tempData[textFieldOne.text] = textFieldTwo.text
        data.insert(tempData, atIndex: selectedItem)
        data.removeAtIndex(selectedItem + 1)
        collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedItem, inSection: 0)])
    }
    
    func checkKeyCount () {
        if data.count == 1 {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
            navigationItem.leftBarButtonItem?.enabled = false
            
            defaultTextLabel.hidden = false
            defaultTextLabel.alpha = 1.0
            
            for view in [editKeysButton, textFieldOne, instructionalLabel, collectionView!] {
                view.alpha = 0.0
                view.hidden = true
            }
            
            self.collectionView?.backgroundColor = UIColor.clearColor()
        }
        else if data.count > 1 {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.enabled = true
                
                self.defaultTextLabel.hidden = true
                self.defaultTextLabel.alpha = 0.0
                
                for view in [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!] {
                    view.alpha = 1.0
                    view.hidden = false
                }
            })
        }
    }
    
    func editButtonPressed () {
        textFieldTwo.text = ""
        textFieldOne.text = ""
        textFieldThree.text = ""
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
            for view in [self.colorPaletteView, self.deleteKeysButton, self.textFieldOne, self.textFieldTwo, self.editKeysButton, self.questionButton, self.instructionalLabel] {
                view.alpha = 0.0
            }
            self.containerView.removeConstraints(self.expandedVConstraints as! [NSLayoutConstraint])
            self.containerView.removeConstraints(self.expandedHConstraints as! [NSLayoutConstraint])
            self.containerView.addConstraints(self.compactVConstraints as! [NSLayoutConstraint])
            self.instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
            self.editKeysButton.setTitle("Edit keys", forState: .Normal)
            self.collectionView?.reloadData()
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
        self.sharedDefaults?.setValue(data, forKey:defaultskey)
        self.sharedDefaults?.setValue(colors, forKey:defaultColors)
        self.sharedDefaults?.synchronize()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonCell", forIndexPath: indexPath) as! PreviewCell
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor.clearColor().CGColor
        cell.backgroundColor = UIColor.lightGrayColor()
        let dict = data[indexPath.item]
        
        if indexPath.item == selectedItem && editKeysButton.selected == true {
            var dict = self.data[self.selectedItem]
            var key = dict.keys.first!
            if colors[key] != nil {
                cell.circleView?.backgroundColor = colorRef[colors[key]!.toInt()!]
                cell.keyTextLabel?.textColor = UIColor.lightTextColor()
            }
            else {
                cell.circleView?.backgroundColor = UIColor.lightTextColor()
                cell.keyTextLabel?.textColor = UIColor.darkTextColor()
            }
            cell.layer.borderColor = view.tintColor.CGColor
            cell.layer.borderWidth = 5
        }
        
        for (key, value) in dict {
            cell.setLabelText(key)
            let colorIndex = colors[key]
            
            if key == "Next Keyboard" || colors[key] == nil {
                cell.circleView?.backgroundColor = UIColor.darkGrayColor()
                cell.keyTextLabel?.textColor = UIColor.whiteColor()
            }
            else {
                cell.circleView?.backgroundColor = colorRef[colorIndex!.toInt()!] as UIColor!
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
        self.sharedDefaults?.setValue(data, forKey:defaultskey)
        self.sharedDefaults?.synchronize()
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
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

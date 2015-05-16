//
//  PreviewViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource {
    
    var collectionView : UICollectionView?
    
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var count = 0
    var selectedRow = 0
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? PreviewCell
        
        var originalColor = cell?.backgroundColor
        
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
    
    override func viewDidLoad() {
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
        collectionView = UICollectionView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, view.frame.width, 305), collectionViewLayout: layout)
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
        
        textFieldOne?.borderStyle = UITextBorderStyle.Line
        textFieldOne?.userInteractionEnabled = false
        textFieldOne?.frame = CGRectMake(20, 430, view.frame.width - 40, 44)
        textFieldOne?.textAlignment = .Center
        textFieldOne?.layer.borderWidth = 1.0
        textFieldOne?.layer.borderColor = UIColor.lightGrayColor().CGColor
        view.addSubview(textFieldOne!)
        
        view.addConstraint(NSLayoutConstraint(item: defaultTextLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: defaultTextLabel!, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 120))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[instructionalLabel]-100-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["instructionalLabel":instructionalLabel!]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[instructionalLabel]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["instructionalLabel":instructionalLabel!]))
        
        editKeysButton = UIButton()
        editKeysButton?.setTitle("Edit Keys", forState: .Normal)
        editKeysButton?.setTitleColor(view.tintColor, forState: .Normal)
        editKeysButton?.showsTouchWhenHighlighted = true
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
        // 1 animate textfield move to just below collecionview
        // change textfield t0 user ineraction enabled
        // animate in 2nd textfield
        // change instruction label text to key editing text
        // change edit keys title to exit and save
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

class PreviewCell: UICollectionViewCell {
    
    var keyTextLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyTextLabel = UILabel()
        keyTextLabel?.textColor = UIColor.whiteColor()
        keyTextLabel?.numberOfLines = 0
        keyTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        keyTextLabel?.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(keyTextLabel!)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["keyTextLabel":keyTextLabel!]))
        contentView.addConstraint(NSLayoutConstraint(item: keyTextLabel!, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    func setLabelText (text: String) {
        keyTextLabel?.text = text
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

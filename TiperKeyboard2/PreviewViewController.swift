//  PreviewViewController.swift
//  TiperKeyboard2
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.

import UIKit
import StoreKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    var scrollView = UIScrollView()
    var containerView = UIView()
    var expandedVConstraints = [NSLayoutConstraint](), expandedHConstraints = [NSLayoutConstraint](), compactVConstraints = [NSLayoutConstraint]()
    var collectionView : UICollectionView?
    var data = [[String:String]]()
    var tempData = [String:String]()
    var count = 0, selectedItem = 0
    var lastContentOffSet : CGFloat = 0.0
    var colors = [String:String]()
    var sharedDefaults = UserDefaults(suiteName: "group.InfoKeyboard")
    let textFieldOne = UITextField(), textFieldTwo = UITextField(), textFieldThree = UITextField()
    let defaultTextLabel = UILabel(), instructionalLabel = UILabel()
    let editKeysButton = UIButton(), deleteKeysButton = UIButton(), questionButton = UIButton(), deleteButton = UIButton(), nextKBButton = UIButton()
    let layout = ReorderableCollectionViewFlowLayout()
    var isUpgradedUser = false
    let defaultskey = "tiper2Keyboard", defaultUpgraded = "tiper2Upgraded"
    let sizeBucket = SizeBucket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.textChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = "Short Key"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(PreviewViewController.addNewItem))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(PreviewViewController.saveDataButtonPressed))
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if sharedDefaults?.object(forKey: defaultUpgraded) != nil {
            isUpgradedUser = sharedDefaults?.object(forKey: defaultUpgraded) as! Bool
        }
        
        if sharedDefaults?.object(forKey: defaultskey) != nil {
            data = sharedDefaults?.object(forKey: defaultskey) as! [[String:String]]
            
            var tempDict = [String:String]()
            for (key, value) in colors {
                _ = data.map { dict -> [String:String] in
                    if dict[key] != nil {
                        tempDict[key] = value
                    }
                    return dict
                }
            }
            
            // clean out the next keyboard / delete button button
            let tempData = data
            for (index, dict) in tempData.enumerated() {
                for key in dict.keys {
                    if key == "Next keyboard" {
                        data.remove(at: index)
                    }
                }
            }
            
            sharedDefaults?.synchronize()
            
            isUpgradedUser = true
            sharedDefaults?.set(true, forKey: defaultUpgraded)
        }
        
        count = data.count
        
        setUpUIElements()
        setUpLayout()
        checkKeyCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        clearText()
        if data.count == 9 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveData()
    }
    
    // MARK Notifications
    func keyboardHidden (_ notif : Notification) {
        if editKeysButton.isSelected == false  && UIScreen.main.bounds.height < 600 {
            scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height))
        }
        else {
            scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 44)
        }
    }
    
    func textChanged (_ notification:Notification) {
        if navigationController?.topViewController == self {
            tempData = [String:String]()
            let textField = notification.object as! UITextField
            textField.clearButtonMode = UITextFieldViewMode.whileEditing
            tempData[textFieldOne.text!] = textFieldTwo.text
            data.insert(tempData, at: selectedItem)
            data.remove(at: selectedItem + 1)
            collectionView?.reloadItems(at: [IndexPath(item: selectedItem, section: 0)])
        }
    }
    
    func checkKeyCount () {
        if data.count == 0 {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
            navigationItem.leftBarButtonItem?.isEnabled = false
            
            defaultTextLabel.isHidden = false
            defaultTextLabel.alpha = 1.0
            
            _ = [editKeysButton, textFieldThree, instructionalLabel, collectionView!, questionButton, deleteButton, nextKBButton].map{$0.alpha = 0.0}
            _ = [editKeysButton, textFieldThree, instructionalLabel, collectionView!, questionButton, deleteButton, nextKBButton].map{$0.isHidden = true}
        }
        else if data.count > 0 {
            UIView.animate(withDuration: 1.0, animations: {
                self.navigationItem.leftBarButtonItem?.tintColor = self.view.tintColor
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                
                self.defaultTextLabel.isHidden = true
                self.defaultTextLabel.alpha = 0.0
                
                _ = [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!, self.questionButton, self.deleteButton, self.nextKBButton].map{$0.alpha = 1.0}
                _ = [self.editKeysButton, self.textFieldThree, self.instructionalLabel, self.collectionView!, self.questionButton, self.deleteButton, self.nextKBButton].map{$0.isHidden = false}
            })
        }
    }
    
    // MARK Actions
    func questionButtonPressed () {
        let infoView = InformationViewController()
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    func deleteButtonPressed () {
        if data.count > 0 {
            data.remove(at: selectedItem)
            saveData()
            collectionView?.deleteItems(at: [IndexPath(item: selectedItem, section: 0)])
            if data.count == 1 {
                UIView.animate(withDuration: 1.0, animations: {
                    self.deleteKeysButton.alpha = 0.0
                    self.deleteKeysButton.isHidden = true
                })
            }
        }
        navigationItem.rightBarButtonItem?.tintColor = view.tintColor
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func editButtonPressed () {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height))
        clearText()
        tempData.removeAll(keepingCapacity: false)
        editKeysButton.isSelected = !editKeysButton.isSelected
        if editKeysButton.isSelected {
            UIView.animate(withDuration: 0.5, animations: {
                _ = [self.textFieldOne, self.textFieldTwo, self.textFieldThree, self.editKeysButton, self.instructionalLabel, self.questionButton].map{$0.alpha = 0.0}
                }) { (value) in
                    self.instructionalLabel.text = "Touch a key to edit it"
                    self.editKeysButton.setTitle("Done", for: UIControlState())
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.instructionalLabel.alpha = 1.0
                        self.editKeysButton.alpha = 1.0
                        self.questionButton.alpha = 1.0
                        }, completion: { (value) in })
            }
        }
        else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: -(navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)), animated: true)
            _ = [deleteKeysButton, textFieldOne, textFieldTwo, editKeysButton, questionButton, instructionalLabel].map{$0.alpha = 0.0}
            
            NSLayoutConstraint.deactivate(expandedVConstraints)
            NSLayoutConstraint.deactivate(expandedHConstraints)
            NSLayoutConstraint.activate(compactVConstraints)
            instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
            editKeysButton.setTitle("Edit keys", for: UIControlState())
            collectionView?.reloadData()
            UIView.animate(withDuration: 0.4, animations: {
                _ = [self.textFieldThree, self.editKeysButton, self.questionButton, self.instructionalLabel].map {$0.alpha = 1.0}
                self.textFieldThree.isHidden = false
                }, completion: { (value) in })
        }
    }
    
    func addNewItem () {
        if count < 10 {
            count += 1
            data.insert(["Add a Title":"Press Edit Keys to add data."], at: 0)
            checkKeyCount()
            collectionView?.reloadData()
        }
        if count == 9 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func saveDataButtonPressed () {
        RKDropdownAlert.title("Saved", backgroundColor: UIColor(red: 48/255, green: 160/255, blue: 61/255, alpha: 1.0), textColor: UIColor.white, time: 1)
        saveData()
    }
    
    // MARK Collectionview methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = (indexPath as NSIndexPath).item
        let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell
        let originalColor = cell?.contentView.backgroundColor
        
        if editKeysButton.isSelected == false {
            UIView.animate(withDuration: 0.2, animations: {
                cell?.contentView.backgroundColor = UIColor.darkGray
                }, completion: { (value: Bool) in
                    UIView.animate(withDuration: 0.2, animations: {
                        cell?.contentView.backgroundColor = originalColor
                    })
            })
            let keyDict = data[(indexPath as NSIndexPath).item]
            for value in keyDict.values {
                textFieldThree.text = value
            }
        }
        else {
            instructionalLabel.alpha = 0.0
            NSLayoutConstraint.deactivate(compactVConstraints)
            NSLayoutConstraint.activate(expandedVConstraints)
            NSLayoutConstraint.activate(expandedHConstraints)
            textFieldOne.placeholder = "What is the name of this key?"
            //textFieldOne.attributedPlaceholder = AttributedString(string: "What is the name of this key?", attributes: [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:UIFont.systemFont(ofSize: 14)])
            //textFieldTwo.attributedPlaceholder = AttributedString(string: "What will this key type when pressed?", attributes: [NSForegroundColorAttributeName:UIColor.white(), NSFontAttributeName:UIFont.systemFont(ofSize: 14)])
            
            instructionalLabel.text = "Press + to add keys.  Press Save to bind.  Press delete to remove a key."
            if UIScreen.main.bounds.height < 600 {
                scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 44)
            }
            else {
                scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height))
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                if self.data.count > 0 {
                    self.deleteKeysButton.alpha = 1.0
                    self.deleteKeysButton.isHidden = false
                }
                
                _ = [self.textFieldOne, self.textFieldTwo].map { textField -> UITextField in
                    textField.alpha = 1.0
                    textField.isHidden = false
                    textField.isUserInteractionEnabled = true
                    textField.text = ""
                    return textField
                }
                
                self.textFieldThree.alpha = 0.0
                self.textFieldThree.isHidden = true
                self.instructionalLabel.alpha = 1.0
                
                }, completion: { (value) in
                    self.collectionView!.reloadData()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonCell", for: indexPath) as! PreviewCell
        cell.layer.borderColor = UIColor.clear.cgColor
        let dict = data[(indexPath as NSIndexPath).item]
        
        if (indexPath as NSIndexPath).item == selectedItem && editKeysButton.isSelected == true {
            cell.layer.borderColor = view.tintColor.cgColor
            cell.layer.borderWidth = 5
        }
        
        cell.contentView.layer.cornerRadius = 2
        
        for key in dict.keys {
            cell.setLabelText(key)
        }
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            cell.isHidden = false
            cell.alpha = 1.0
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeBucket.getSizes(data.count, indexOfItem: (indexPath as NSIndexPath).item, frame : collectionView.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {
        let keyBeingMoved = data[fromIndexPath.item]
        data.remove(at: fromIndexPath.item)
        data.insert(keyBeingMoved, at: toIndexPath.item)
        saveData()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
        if toIndexPath.item < (data.count - 1) {
            return true
        }
        return false
    }
    
    // MARK Scroll view delegate methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for textField in [textFieldOne, textFieldTwo] {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
    
    // MARK Convenience
    func clearText () {
        _ = [textFieldOne, textFieldThree, textFieldThree].map{$0.text = ""}
    }
    
    func saveData () {
        print(data)
        sharedDefaults?.setValue(data, forKey:defaultskey)
        sharedDefaults?.synchronize()
    }
    
    // MARK Textfield delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder == true {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK keyboard notifications
    func keyboardShown (_ notification : Notification) {
        if UIScreen.main.bounds.height < 600 {
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + keyboardSize.height)
                scrollView.setContentOffset(CGPoint(x: 0.0, y: textFieldTwo.frame.origin.y - keyboardSize.height), animated: true)
            }
        }
    }
}

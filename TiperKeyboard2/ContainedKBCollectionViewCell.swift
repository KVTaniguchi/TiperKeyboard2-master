//
//  ContainedKBCollectionViewCell.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 7/18/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class ContainedKBCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, ReorderableCollectionViewDelegateFlowLayout, ReorderableCollectionViewDataSource {
    
    var collectionView : UICollectionView?
    var keyData = [[String:String]]()
    var selectedItem = 0
    var editingEnabled = false
    var colors = [String:String]()
    let colorRef = ColorPalette.colorRef
    let sizeBucket = SizeBucket()
    var count = 0
    var animateCallbackWithData : ( (count : Int) -> () )?
    var updateAllDataWithData: ( (data : [[String:String]]) -> () )?
    var updateTextField: ( (text : String) -> () )?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var layout = ReorderableCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.contentSize = CGSizeMake(contentView.frame.width, 260)
        contentView.addSubview(collectionView!)
        
        let leftConstraints = NSLayoutConstraint(item: collectionView!, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightContraints = NSLayoutConstraint(item: collectionView!, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: collectionView!, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        NSLayoutConstraint.activateConstraints([leftConstraints, rightContraints, topConstraint, bottomConstraint])
    }
    
    // MARK Actions
    func addNewKey () {
        if keyData.count < 8 {
            count++
            keyData.insert(["Add a Title":"Press Edit Keys to add data."], atIndex: 0)
            collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            updateAllDataWithData?(data: keyData)
            
            if editingEnabled == true {
                collectionView?.visibleCells().map{$0.layer.borderColor = UIColor.clearColor().CGColor}
            }
        }
    }
    
    func configureKBCellWithData (data : [[String:String]], isEditing: Bool, keyColors : [String:String]) {
        keyData = data
        colors = keyColors
        editingEnabled = isEditing
        collectionView?.reloadData()
    }
    
    func updateCellTextWithText(text : String) {
        let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: selectedItem, inSection: 0)) as! PreviewCell
        cell.setLabelText(text)
    }
    
    func updateCellCircleViewWithColor (color : Int) {
        let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: selectedItem, inSection: 0)) as! PreviewCell
        cell.circleView.backgroundColor = colorRef[color]
    }
    
    // MARK Collection Methods
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var previousCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selectedItem, inSection: 0))
        previousCell?.layer.borderColor = UIColor.clearColor().CGColor
        
        selectedItem = indexPath.item
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? PreviewCell
        var originalColor = cell?.contentView.backgroundColor
        
        if editingEnabled == false {
            UIView.animateWithDuration(0.2, animations: {
                cell?.contentView.backgroundColor = UIColor.darkGrayColor()
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.2, animations: {
                        cell?.contentView.backgroundColor = originalColor
                    })
            })
            var keyDict = keyData[indexPath.item]
            for (key, value) in keyDict {
                updateTextField?(text: value)
            }
        }
        else {
            if indexPath.item == (keyData.count - 1) {
                return
            }
            animateCallbackWithData?(count: keyData.count)
            cell?.layer.borderColor = contentView.tintColor.CGColor
            cell?.layer.borderWidth = 5.0
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonCell", forIndexPath: indexPath) as! PreviewCell
        cell.layer.borderColor = UIColor.clearColor().CGColor
        let dict = keyData[indexPath.item]
        
        if indexPath.item == selectedItem && editingEnabled == true {
            cell.layer.borderColor = contentView.tintColor.CGColor
            cell.layer.borderWidth = 5
        }
        
        for (key, value) in dict {
            cell.setLabelText(key)
            let colorIndex = colors[key]
            cell.circleView.backgroundColor = colors[key] == nil ? UIColor.clearColor() : colorRef[colorIndex!.toInt()!] as UIColor!
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyData.count
    }
    
    // MARK Flow Layout Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeBucket.getSizes(collectionView.frame, count: keyData.count, indexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let keyBeingMoved = keyData[fromIndexPath.item]
        keyData.removeAtIndex(fromIndexPath.item)
        keyData.insert(keyBeingMoved, atIndex: toIndexPath.item)
        updateAllDataWithData!(data : keyData)
    }

    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.item < (keyData.count-1) {
            return true
        }
        return false
    }

    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item < (keyData.count - 1) {
            return true
        }
        return false
    }

    required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}

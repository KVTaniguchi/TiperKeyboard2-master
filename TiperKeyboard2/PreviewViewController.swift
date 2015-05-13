//
//  PreviewViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/10/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView : UICollectionView?
    
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var colors = [String:String]()
    var buttonArray = [UIButton]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    let colorRef = ColorPalette.colorRef
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.whiteColor()
        
        if sharedDefaults?.objectForKey(defaultskey) != nil {
            data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
            colors = self.sharedDefaults?.objectForKey(defaultColors) as! [String:String]
            data.append(["Next Keyboard":"Next Keyboard"])
            colors["Next Keyboard"] = "0"
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView = UICollectionView(frame: CGRectMake(0, 70, view.frame.width, 305), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.lightGrayColor()
        collectionView!.registerClass(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        view.addSubview(collectionView!)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonCell", forIndexPath: indexPath) as! PreviewCell
        
        cell.layer.cornerRadius = 10
        
        let dict = data[indexPath.item]
        for (key, value) in dict {
            cell.setLabelText(value)
            let colorIndex = colors[key]
            cell.backgroundColor = colorRef[colorIndex!.toInt()!] as UIColor!
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
        case 2:
            size = CGSizeMake((collectionView.frame.width/2) - 2, collectionView.frame.height-2)
        case 3:
            size = CGSizeMake(collectionView.frame.width - 2, collectionView.frame.height/3 - 2)
        case 4:
            size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/2) - 2)
        case 5:
            if indexPath.item < 2 {
                size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/2) - 2)
            }
            else {
                size = CGSizeMake(collectionView.frame.width - 2, collectionView.frame.height/3 - 2)
            }
        case 6:
            size = CGSizeMake((collectionView.frame.width/2) - 2, (collectionView.frame.height/3) - 2)
        case 7:
            if indexPath.item < 3 {
                size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/3)
            }
            else {
                size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/4)
            }
        case 8:
            size = CGSizeMake(collectionView.frame.width/2 - 2, collectionView.frame.height/4)
        default:
            println("2")
        }
        
        return size
    }
}

class PreviewCell: UICollectionViewCell {
    
    var keyTextLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyTextLabel = UILabel()
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

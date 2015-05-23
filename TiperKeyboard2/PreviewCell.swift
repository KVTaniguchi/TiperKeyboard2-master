//
//  PreviewCell.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/16/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    var keyTextLabel : UILabel?
    var circleView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyTextLabel = UILabel()
        keyTextLabel?.textColor = UIColor.whiteColor()
        keyTextLabel?.numberOfLines = 2
        keyTextLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        keyTextLabel?.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(keyTextLabel!)
        
        circleView = UIView()
        circleView?.layer.cornerRadius = 10
        circleView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(circleView!)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel][circle(20)]-5-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel!, "circle":circleView!]))
        contentView.addConstraint(NSLayoutConstraint(item: keyTextLabel!, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[circle(20)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["circle":circleView!]))
    }
    
    func setLabelText (text: String) {
        keyTextLabel?.text = text
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

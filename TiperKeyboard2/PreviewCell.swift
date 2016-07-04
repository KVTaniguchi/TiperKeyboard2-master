//
//  PreviewCell.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 5/16/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    let keyTextLabel = UILabel()
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.lightGrayColor()
        keyTextLabel.textColor = UIColor.whiteColor()
        keyTextLabel.translatesAutoresizingMaskIntoConstraints = false
        keyTextLabel.numberOfLines = 2
        keyTextLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        keyTextLabel.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel.font = UIFont(name: "Helvetica", size: 10)
        contentView.addSubview(keyTextLabel)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel]))
        keyTextLabel.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
        
        contentView.clipsToBounds = true
    }
    
    func setLabelText (text: String) {
        keyTextLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

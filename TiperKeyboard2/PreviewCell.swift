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
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.lightGray
        keyTextLabel.textColor = UIColor.white
        keyTextLabel.translatesAutoresizingMaskIntoConstraints = false
        keyTextLabel.numberOfLines = 2
        keyTextLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        keyTextLabel.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel.font = UIFont(name: "Helvetica", size: 10)
        contentView.addSubview(keyTextLabel)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[keyTextLabel]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel]))
        keyTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        contentView.clipsToBounds = true
    }
    
    func setLabelText (_ text: String) {
        keyTextLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }    
}

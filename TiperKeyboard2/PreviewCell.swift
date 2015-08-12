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
    let imageView = UIImageView(image: UIImage(named: "keyboard-75"))
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.lightGrayColor()
        keyTextLabel.textColor = UIColor.whiteColor()
        keyTextLabel.numberOfLines = 2
        keyTextLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        keyTextLabel.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel.frame = contentView.frame
        keyTextLabel.backgroundColor = UIColor.orangeColor()
        keyTextLabel.font = UIFont(name: "Helvetica", size: 10)
        contentView.addSubview(keyTextLabel)
        
        contentView.clipsToBounds = true
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel]-5-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel]))
        contentView.addConstraint(NSLayoutConstraint(item: keyTextLabel, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(imageView)
        imageView.hidden = true
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView]))
    }
    
    func setLabelText (text: String) {
        keyTextLabel.text = text
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

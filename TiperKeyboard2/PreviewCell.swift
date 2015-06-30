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
    let circleView = UIView()
    let imageView = UIImageView(image: UIImage(named: "keyboard-75"))
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = UIColor.lightGrayColor()
        keyTextLabel.textColor = UIColor.whiteColor()
        keyTextLabel.numberOfLines = 2
        keyTextLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        keyTextLabel.preferredMaxLayoutWidth = contentView.frame.width - 2
        keyTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(keyTextLabel)
        
        circleView.layer.cornerRadius = 10
        circleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(circleView)
        
        // Set vertical effect
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        circleView.addMotionEffect(group)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel][circle(20)]-5-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel, "circle":circleView]))
        contentView.addConstraint(NSLayoutConstraint(item: keyTextLabel, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[circle(20)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["circle":circleView]))
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(imageView)
        imageView.hidden = true
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView]))
    }
    
    func setLabelText (text: String) {
        if text == "Next Keyboard"{
            keyTextLabel.hidden = true
            circleView.hidden = true
            imageView.hidden = false

        }
        else {
            keyTextLabel.hidden = false
            circleView.hidden = false
            imageView.hidden = true
            keyTextLabel.text = text
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

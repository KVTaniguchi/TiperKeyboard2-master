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
    var imageView : UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = UIColor.lightGrayColor()
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
        
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        circleView?.addMotionEffect(group)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyTextLabel][circle(20)]-5-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["keyTextLabel":keyTextLabel!, "circle":circleView!]))
        contentView.addConstraint(NSLayoutConstraint(item: keyTextLabel!, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[circle(20)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["circle":circleView!]))
        
        imageView = UIImageView(image: UIImage(named: "keyboard-75"))
        imageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(imageView!)
        imageView?.hidden = true
        contentView.addConstraint(NSLayoutConstraint(item: imageView!, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView!, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView!]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[img(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["img":imageView!]))
    }
    
    func setLabelText (text: String) {
        if text == "Next Keyboard"{
            keyTextLabel?.hidden = true
            circleView?.hidden = true
            imageView?.hidden = false

        }
        else {
            keyTextLabel?.hidden = false
            circleView?.hidden = false
            imageView?.hidden = true
            keyTextLabel?.text = text
        }
    }
    
    func addDepth () {
        let border = CALayer()
        border.backgroundColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRectMake(3, contentView.frame.height - 0.5, contentView.frame.width - 6.5, 0.5)
        contentView.layer.addSublayer(border)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

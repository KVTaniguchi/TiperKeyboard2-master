//
//  UserDataCellTableViewCell.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class UserDataCellTableViewCell: UITableViewCell {

    var buttonArray = [UIButton]()
    var colors = [UIColor]()
    var colorButton : UIButton!
    var userEmailTextField : UITextField!
    var userNameTextField : UITextField!
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var lockLeftSideOpen = false
    let gradientLayer = CAGradientLayer()
    
    var updateColorCallback : ((keyName : String, colorIndex: String) -> ())?
    var deleteItemCallback : ((tag : Int) -> ())?
    var slideBeganCallback : ((tag : Int) -> ())?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.userNameTextField = UITextField()
        self.userEmailTextField = UITextField()
        self.userNameTextField?.textAlignment = NSTextAlignment.Center
        self.userEmailTextField?.textAlignment = NSTextAlignment.Center
        self.userEmailTextField.backgroundColor = UIColor.clearColor()
        self.userNameTextField.backgroundColor = UIColor.clearColor()
        self.userEmailTextField.textColor = UIColor.whiteColor()
        self.userNameTextField.textColor = UIColor.whiteColor()
        self.userEmailTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.userNameTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if self.userNameTextField?.text.isEmpty == true {
            self.userNameTextField?.placeholder = "What you want the key to say"
        }
        if self.userEmailTextField?.text.isEmpty == true {
            self.userEmailTextField?.placeholder = "Name of this key"
        }
        
        self.userNameTextField?.clearsOnBeginEditing = false
        self.userEmailTextField?.clearsOnBeginEditing = false
        self.userNameTextField.clearButtonMode = UITextFieldViewMode.Always
        self.userEmailTextField.clearButtonMode = UITextFieldViewMode.Always
        self.contentView.addSubview(self.userEmailTextField!)
        self.contentView.addSubview(self.userNameTextField!)
        
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        self.contentView.addGestureRecognizer(recognizer)
        
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        gradientLayer.frame = bounds
        
        var animatingView = UIView()
        animatingView.backgroundColor = UIColor.lightGrayColor()
        
        UIView.animateKeyframesWithDuration(2.0, delay: 0, options: UIViewKeyframeAnimationOptions.Autoreverse | UIViewKeyframeAnimationOptions.Repeat, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                    animatingView.backgroundColor = UIColor(red: 51/255, green: 56/255, blue: 239/255, alpha: 1.0)
                })
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                    animatingView.backgroundColor = UIColor.lightGrayColor()
                })
            }, completion: nil)
    
        animatingView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(animatingView)
        
        self.colors = [UIColor.greenColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.darkGrayColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.magentaColor(), UIColor.purpleColor(), UIColor.lightGrayColor(), UIColor.brownColor()]
        
        for index in 0...9 {
            var colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton.tag = index
            colorButton.addTarget(self, action: "activateColorPicker:", forControlEvents: UIControlEvents.TouchUpInside)
            colorButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            colorButton.backgroundColor = colors[index]
            self.buttonArray.append(colorButton)
            self.contentView.addSubview(colorButton)
            
            if index == 0 {
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 0))
            }
            else {
                let previousButton = self.buttonArray[index - 1]
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Left, relatedBy: .Equal, toItem: previousButton, attribute: .Right, multiplier: 1.0, constant: 0))
                if index == 9 {
                    self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Right, relatedBy: .Equal, toItem: animatingView, attribute: .Left, multiplier: 1.0, constant: 0))
                }
            }
            
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[colorButton]|", options: NSLayoutFormatOptions(0), metrics: nil, views:["colorButton":colorButton]))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[colorButton(30)]", options: NSLayoutFormatOptions(0), metrics: nil, views:["colorButton":colorButton]))
        }
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[emailTF][nameTF]|", options:.AlignAllLeading | .AlignAllTrailing, metrics: nil, views: ["emailTF":self.userEmailTextField, "nameTF":self.userNameTextField]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[animatingView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["animatingView":animatingView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[animatingView(10)][emailTF]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["emailTF":self.userEmailTextField, "animatingView":animatingView]))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.userNameTextField!, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.userEmailTextField!, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
    }
    
    func handlePan (recognizer : UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            originalCenter = center
            self.slideBeganCallback!(tag : self.tag)
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self.contentView)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            deleteOnDragRelease = frame.origin.x < (-frame.size.width + 300 ) / 2.0
            lockLeftSideOpen = frame.origin.x > (frame.size.width + 300) / 4.0
        }
        
        if recognizer.state == .Ended {
            let originalFrame = CGRectMake(0, frame.origin.y, bounds.size.width, bounds.size.height)
            if !deleteOnDragRelease && !lockLeftSideOpen {
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = originalFrame
                })
            }
            else if lockLeftSideOpen {
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = CGRectMake(300, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height)
                })
                
            }
            else {
                self.deleteItemCallback!(tag: self.tag)
            }
        }
    }
    
    func activateColorPicker (sender : UIButton) {
        self.contentView.backgroundColor = self.colors[sender.tag]
//        self.updateColorCallback!(tag: sender.tag)
//            var updateColorCallback : ((keyName : String, colorIndex: String) -> ())?
        self.updateColorCallback!(keyName: self.userNameTextField.text, colorIndex: "\(sender.tag)")
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
        }
        return false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

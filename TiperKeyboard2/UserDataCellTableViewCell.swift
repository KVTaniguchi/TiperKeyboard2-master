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
    var keyInputDataTextField : UITextField!
    var keyNameTextField : UITextField!
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
        
        self.keyNameTextField = UITextField()
        self.keyInputDataTextField = UITextField()
        self.keyNameTextField?.textAlignment = NSTextAlignment.Center
        self.keyInputDataTextField?.textAlignment = NSTextAlignment.Center
        self.keyInputDataTextField.backgroundColor = UIColor.clearColor()
        self.keyNameTextField.backgroundColor = UIColor.clearColor()
        self.keyInputDataTextField.textColor = UIColor.whiteColor()
        self.keyNameTextField.textColor = UIColor.whiteColor()
        self.keyInputDataTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.keyNameTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if self.keyNameTextField?.text.isEmpty == true {
            self.keyNameTextField?.placeholder = "Name of this key"
        }
        if self.keyInputDataTextField?.text.isEmpty == true {
            self.keyInputDataTextField?.placeholder = "What you want the key to say"
        }
        
        self.keyNameTextField?.clearsOnBeginEditing = false
        self.keyInputDataTextField?.clearsOnBeginEditing = false
        self.keyNameTextField.clearButtonMode = UITextFieldViewMode.Always
        self.keyInputDataTextField.clearButtonMode = UITextFieldViewMode.Always
        self.contentView.addSubview(self.keyInputDataTextField!)
        self.contentView.addSubview(self.keyNameTextField!)
        
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
        
        var rightArrowImageView = UIImageView(image: UIImage(named: "forward-7"))
    
        rightArrowImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(rightArrowImageView)
        
        let green = UIColor(red: 103/255.0, green: 113/255, blue: 72/255, alpha: 1.0)
        let purple = UIColor(red: 70/255, green: 52/255, blue: 109/255, alpha: 1.0)
        let blue = UIColor(red: 53/255, green: 76/255, blue: 116/255, alpha: 1.0)
        let lightYellow = UIColor(red: 122/255, green: 116/255, blue: 50/255, alpha: 1.0)
        let pumpkin = UIColor(red: 118/255, green: 86/255, blue: 43/255, alpha: 1.0)
        let gold = UIColor(red: 180/255, green: 149/255, blue: 0/255, alpha: 1.0)
        let majestic = UIColor(red: 138/255, green: 0/255, blue: 63/255, alpha: 1.0)
        let brightRed = UIColor(red: 213/255, green: 17/255, blue: 17/255, alpha: 1.0)
        let deepGreen = UIColor(red: 23/255, green: 50/255, blue: 0/255, alpha: 1.0)
        let turq = UIColor(red: 12/255, green: 56/255, blue: 64/255, alpha: 1.0)
        
        self.colors = [green, purple, blue, lightYellow, pumpkin, gold, majestic, brightRed, deepGreen, turq]
        
        for index in 0...9 {
            var colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            colorButton.tag = index
            colorButton.addTarget(self, action: "activateColorPicker:", forControlEvents: UIControlEvents.TouchUpInside)
            colorButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            colorButton.backgroundColor = colors[index]
            self.buttonArray.append(colorButton)
            self.contentView.addSubview(colorButton)
            
            if index == 0 || index == 5 {
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 0))
            }
            else {
                let previousButton = self.buttonArray[index - 1]
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Left, relatedBy: .Equal, toItem: previousButton, attribute: .Right, multiplier: 1.0, constant: 0))
                if index == 9 || index == 4 {
                    self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Right, relatedBy: .Equal, toItem: rightArrowImageView, attribute: .Left, multiplier: 1.0, constant: 0))
                }
            }
            
            if index < 5 {
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0))
            }
            else {
                self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }
            
            self.contentView.addConstraint(NSLayoutConstraint(item: colorButton, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[colorButton(60)]", options: NSLayoutFormatOptions(0), metrics: nil, views:["colorButton":colorButton]))
        }
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[nameTF][emailTF]|", options:.AlignAllLeading | .AlignAllTrailing, metrics: nil, views: ["nameTF":self.keyNameTextField, "emailTF":self.keyInputDataTextField]))
        self.contentView.addConstraint(NSLayoutConstraint(item: rightArrowImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[rightArrowImageView(20)][emailTF]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["emailTF":self.keyInputDataTextField, "rightArrowImageView":rightArrowImageView]))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.keyNameTextField!, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.keyInputDataTextField!, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
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
        self.updateColorCallback!(keyName: self.keyNameTextField.text, colorIndex: "\(sender.tag)")
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

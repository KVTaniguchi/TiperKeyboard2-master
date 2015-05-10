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

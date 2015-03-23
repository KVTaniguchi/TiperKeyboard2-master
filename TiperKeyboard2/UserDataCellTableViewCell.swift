//
//  UserDataCellTableViewCell.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

protocol UserDataCellDelegate {
    func itemDeleted(tag:NSInteger)
    func slideBegan(tag:NSInteger)
}

class UserDataCellTableViewCell: UITableViewCell {

    var userEmailTextField : UITextField!
    var userNameTextField : UITextField!
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var delegate : UserDataCellDelegate?
    let gradientLayer = CAGradientLayer()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.userNameTextField = UITextField()
        self.userEmailTextField = UITextField()
        self.userNameTextField?.textAlignment = NSTextAlignment.Center
        self.userEmailTextField?.textAlignment = NSTextAlignment.Center
        self.userEmailTextField.backgroundColor = UIColor.clearColor()
        self.userNameTextField.backgroundColor = UIColor.clearColor()
        self.userEmailTextField.textColor = UIColor.whiteColor()
        self.userNameTextField.textColor = UIColor.whiteColor()
        
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
        addGestureRecognizer(recognizer)
        
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        gradientLayer.frame = bounds
        
        self.userEmailTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.userNameTextField?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[emailTF][nameTF]|", options:.AlignAllLeading | .AlignAllTrailing, metrics: nil, views: ["emailTF":self.userEmailTextField, "nameTF":self.userNameTextField]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[emailTF]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["emailTF":self.userEmailTextField]))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.userNameTextField!, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.userEmailTextField!, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: .Height, multiplier: 0.5, constant: 0))
    }
    
    func handlePan (recognizer : UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            originalCenter = center
            delegate?.slideBegan(self.tag)
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
        }
        
        if recognizer.state == .Ended {
            let originalFrame = CGRectMake(0, frame.origin.y, bounds.size.width, bounds.size.height)
            if !deleteOnDragRelease {
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = originalFrame
                })
            }
            else {
                delegate?.itemDeleted(self.tag)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
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

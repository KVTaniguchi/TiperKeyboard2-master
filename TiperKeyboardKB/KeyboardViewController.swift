//
//  KeyboardViewController.swift
//  TiperKeyboardKB
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class KeyButton : UIButton {
    var keyText : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NextKeyboardButton : UIButton {
    var keyboardImage : UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyboardImage = UIImageView(image: UIImage(named: "keyboard-75"))
        keyboardImage?.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(keyboardImage!)
        self.addConstraint(NSLayoutConstraint(item: keyboardImage!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: keyboardImage!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[keyboard(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["keyboard":keyboardImage!]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[keyboard(35)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["keyboard":keyboardImage!]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KeyboardViewController: UIInputViewController {
    
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var colors = [String:String]()
    var buttonArray = [UIButton]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var colorRef = [UIColor]()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()

        if self.sharedDefaults?.objectForKey(defaultskey) != nil {
            self.data = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        }

        self.colors = self.sharedDefaults?.objectForKey(defaultColors) as! [String:String]
        
        self.colorRef = KBColorPalette.colorRef
        
        for (index, entry) in enumerate(self.data) {
            for (key, value) in entry {
                if let var color = self.colors[key] as String! {
                    self.addKeyboardButton(key, tag: index, keyText: value, colorIndex:color)
                }
                else {
                    self.addKeyboardButton(key, tag: index, keyText: value, colorIndex:"0")
                }
            }
        }
    }
    
    func addKeyboardButton (keyTitle: String, tag: NSInteger, keyText: String, colorIndex: String) {
        let keyboardButton = KeyButton.buttonWithType(.Custom) as! KeyButton

        keyboardButton.layer.cornerRadius = 3
        keyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if keyTitle != "Next Keyboard" {
            keyboardButton.setTitle(keyTitle, forState: .Normal)
            keyboardButton.keyText = keyText
            keyboardButton.addTarget(self, action:"keyPressed:", forControlEvents: .TouchUpInside)
            keyboardButton.backgroundColor = self.colorRef[colorIndex.toInt()!] as UIColor!
        }
        else {
            var nextButton = NextKeyboardButton()
            nextButton.backgroundColor = UIColor.darkGrayColor()
            nextButton.layer.cornerRadius = 10
            nextButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            nextButton.addTarget(self, action:"advanceToNextInputMode", forControlEvents: .TouchUpInside)
            
            var deleteButton = UIButton()
            deleteButton.backgroundColor = UIColor.lightGrayColor()
            deleteButton.setTitle("del", forState: UIControlState.Normal)
            deleteButton.layer.cornerRadius = 10
            deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            deleteButton.addTarget(self, action: "deleteWord", forControlEvents: .TouchUpInside)
            
            keyboardButton.addSubview(nextButton)
            keyboardButton.addSubview(deleteButton)
            keyboardButton.addConstraint(NSLayoutConstraint(item: nextButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0))
            keyboardButton.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0))
            keyboardButton.addConstraint(NSLayoutConstraint(item: nextButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0))
            keyboardButton.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0))
            keyboardButton.addConstraint(NSLayoutConstraint(item: nextButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
            keyboardButton.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: keyboardButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
            keyboardButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[next][delete]|", options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: ["next":nextButton, "delete":deleteButton]))
        }

        self.view.addSubview(keyboardButton)
        
        var keyboardTopConstraint = NSLayoutConstraint()
        var keyboardWidth = NSLayoutConstraint()
        var keyboardSideConstraint = NSLayoutConstraint()
        var keyboardHeight = NSLayoutConstraint()
        var sideAttribute : NSLayoutAttribute?
        var topRelationalItem : UIView?
        var topRelationalAttribute : NSLayoutAttribute?
        var keyHeight = 0.0 as CGFloat
        var keyWidth = 0.0 as CGFloat
        
        if self.data.count != 3 {
            keyboardWidth = NSLayoutConstraint(item: keyboardButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier:0.5, constant: 0)
        }
        
        switch self.data.count  {
            case 2:
                topRelationalAttribute = NSLayoutAttribute.Top
                topRelationalItem = view
                keyHeight = 1.0
                if tag == 0 {
                    sideAttribute = NSLayoutAttribute.Left
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                }

            case 3:
                if tag == 0 {
                    topRelationalAttribute = NSLayoutAttribute.Top
                    topRelationalItem = view
                }
                else {
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                }
                keyboardWidth = NSLayoutConstraint(item: keyboardButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier:1.0, constant: 0)
                keyHeight = 0.333
                sideAttribute = NSLayoutAttribute.Left
            case 4:
                if tag == 0 || tag == 2 {
                    topRelationalItem = view
                    topRelationalAttribute = NSLayoutAttribute.Top
                }
                else {
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                }
                if tag == 0 || tag == 1 {
                    sideAttribute = NSLayoutAttribute.Left
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                }
                keyHeight = 0.5

            case 5:
                if tag == 0 || tag == 1 {
                    sideAttribute = NSLayoutAttribute.Left
                    keyHeight = 0.5
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                    keyHeight = 0.333
                }
                if tag == 0 || tag == 2 {
                    topRelationalItem = view
                    topRelationalAttribute = NSLayoutAttribute.Top
                }
                else {
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                }
            
            case 6:
                if tag == 0 || tag == 3 {
                    topRelationalItem = view
                    topRelationalAttribute = NSLayoutAttribute.Top
                }
                else {
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                }
                if tag < 3 {
                    sideAttribute = NSLayoutAttribute.Left
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                }

                keyHeight = 0.333
            case 7:
                if tag < 3 {
                    keyHeight = 0.333
                    sideAttribute = NSLayoutAttribute.Left
                }
                else {
                    keyHeight = 0.25
                    sideAttribute = NSLayoutAttribute.Right
                }
                if tag == 0 || tag == 3 {
                    topRelationalItem = view
                    topRelationalAttribute = NSLayoutAttribute.Top
                }
                else {
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                }
            case 8 :
                if tag == 0 || tag == 4 {
                    topRelationalItem = view
                    topRelationalAttribute = NSLayoutAttribute.Top
                }
                else {
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                }
                if tag < 4 {
                    sideAttribute = NSLayoutAttribute.Left
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                }
    
                keyHeight = 0.25
            default:
                keyHeight = 0.20
                sideAttribute = NSLayoutAttribute.Left
                topRelationalAttribute = NSLayoutAttribute.Top
                topRelationalItem = view
        }
        
        keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: topRelationalItem, attribute: topRelationalAttribute!, multiplier: 1.0, constant: 0)
        keyboardSideConstraint = NSLayoutConstraint(item: keyboardButton, attribute: sideAttribute!, relatedBy: .Equal, toItem: self.view, attribute: sideAttribute! , multiplier: 1.0, constant: 0)
        keyboardHeight = NSLayoutConstraint(item: keyboardButton, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: keyHeight, constant: 0)
        
        self.view.addConstraints([keyboardTopConstraint, keyboardHeight, keyboardWidth, keyboardSideConstraint])
        self.buttonArray.append(keyboardButton)
    }
    
    func keyPressed (button: KeyButton) {
        var originalColor = button.backgroundColor
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            button.backgroundColor = UIColor.lightGrayColor()
        }) { (value) in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                button.backgroundColor = originalColor
            })
        }
        let text = button.keyText
        let proxy = textDocumentProxy as! UITextDocumentProxy
        proxy.insertText(text!)
    }
    
    func deleteWord () {
        let proxy = textDocumentProxy as! UITextDocumentProxy
        proxy.deleteBackward()
        let tokens = proxy.documentContextBeforeInput.componentsSeparatedByString(" ")
        for var index = 0; index  < count(tokens.last!.utf16); index++ {
            proxy.deleteBackward()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func textWillChange(textInput: UITextInput) {
    }

    override func textDidChange(textInput: UITextInput) {
        var textColor: UIColor
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        }
        else {
            textColor = UIColor.blackColor()
        }
    }
}

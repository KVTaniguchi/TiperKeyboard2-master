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

        if self.sharedDefaults?.objectForKey(defaultskey) != nil {
            self.data = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        }

        self.colors = self.sharedDefaults?.objectForKey(defaultColors) as! [String:String]
        
        self.colorRef = KBColorPalette.colorRef

        self.data.append(["Next Keyboard":"Next Keyboard"])
        self.colors["Next Keyboard"] = "10"
        
        for (index, entry) in enumerate(self.data) {
            for (key, value) in entry {
                var color = self.colors[key] as String!
                self.addKeyboardButton(key, tag: index, keyText: value, colorIndex:color)
            }
        }
    }
    
    func addKeyboardButton (keyTitle: String, tag: NSInteger, keyText: String, colorIndex: String) {
        let keyboardButton = KeyButton.buttonWithType(.Custom) as! KeyButton
        keyboardButton.setTitle(keyText, forState: .Normal)
        keyboardButton.keyText = keyTitle
        keyboardButton.layer.cornerRadius = 10
        keyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if keyTitle != "Next Keyboard" {
            keyboardButton.addTarget(self, action:"keyPressed:", forControlEvents: .TouchUpInside)
            keyboardButton.backgroundColor = self.colorRef[colorIndex.toInt()!] as UIColor!
        }
        else {
            keyboardButton.addTarget(self, action:"advanceToNextInputMode", forControlEvents: .TouchUpInside)
            keyboardButton.backgroundColor = UIColor.darkGrayColor()
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
                println("2")
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
                println("3")
                if tag == 0 {
                    topRelationalAttribute = NSLayoutAttribute.Top
                    topRelationalItem = view
                }
                else {
                    topRelationalItem = self.buttonArray[tag - 1] as UIButton
                    topRelationalAttribute = NSLayoutAttribute.Bottom
                }
                keyboardWidth = NSLayoutConstraint(item: keyboardButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier:1.0, constant: 0)
                keyHeight = 0.33
                sideAttribute = NSLayoutAttribute.Left
            case 4:
                println("4")
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
                println("5")
                if tag == 0 || tag == 1 {
                    sideAttribute = NSLayoutAttribute.Left
                    keyHeight = 0.5
                }
                else {
                    sideAttribute = NSLayoutAttribute.Right
                    keyHeight = 0.33
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
                println("6")
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

                keyHeight = 0.33
            case 7:
                println("7")
                if tag < 3 {
                    keyHeight = 0.33
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
                println("8")
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
                println("8")
        }
        
        keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: topRelationalItem, attribute: topRelationalAttribute!, multiplier: 1.0, constant: 0)
        keyboardSideConstraint = NSLayoutConstraint(item: keyboardButton, attribute: sideAttribute!, relatedBy: .Equal, toItem: self.view, attribute: sideAttribute! , multiplier: 1.0, constant: 0)
        keyboardHeight = NSLayoutConstraint(item: keyboardButton, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: keyHeight, constant: 0)
        
        self.view.addConstraints([keyboardTopConstraint, keyboardHeight, keyboardWidth, keyboardSideConstraint])
        self.buttonArray.append(keyboardButton)
    }
    
    func keyPressed (button: KeyButton) {
        let text = button.keyText
        let proxy = textDocumentProxy as!UITextDocumentProxy
        proxy.insertText(text!)
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
    
    func getRandomColor() -> UIColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

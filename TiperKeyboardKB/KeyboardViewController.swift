//
//  KeyboardViewController.swift
//  TiperKeyboardKB
//
//  Created by Kevin Taniguchi on 12/27/14.
//  Copyright (c) 2014 Kevin Taniguchi. All rights reserved.
//

import UIKit

class NextKeyboardButton : UIButton {
    var keyboardImage : UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KeyboardViewController: UIInputViewController {
    var buttonArray = [UIButton]()
    let defaultskey = "tiper2Keyboard"
    let defaultColors = "tiper2Colors"
    var data = [[String:String]]()
    var colors = [String:String]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    var colorRef = KBColorPalette.colorRef
    
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    
    var midScreenWidth : CGFloat {
        get {
            return screenWidth / 2
        }
    }
    
    var midscreenHeight : CGFloat {
        get {
            return screenHeight / 2
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if sharedDefaults?.objectForKey(defaultskey) != nil {
            data = sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        }
        
        if sharedDefaults?.objectForKey(defaultColors) != nil {
            colors = sharedDefaults?.objectForKey(defaultColors) as! [String:String]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        
        for (index, entry) in data.enumerate() {
            for (key, value) in entry {
                if let color = self.colors[key] as String! {
                    addVariableKeySizeButtonWithTitle(key, tag: index, keyText: value, colorIndex: color)
                }
                else {
                    addVariableKeySizeButtonWithTitle(key, tag: index, keyText: value, colorIndex: "\(index)")
                }
            }
        }

        addSystemKeys()
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func addSystemKeys () {
        let nextButton = UIButton()
        nextButton.setImage(UIImage(named: "keyboard-75"), forState: .Normal)
        nextButton.backgroundColor = UIColor.whiteColor()
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action:"advanceToNextInputMode", forControlEvents: .TouchUpInside)
        nextButton.frame = CGRectMake(screenWidth - screenWidth/8, screenHeight - screenWidth/8, screenWidth/8 - 1, screenWidth/8)
        
        let deleteButton = UIButton(type: .Custom)
        deleteButton.setImage(UIImage(named: "delete_sign-50"), forState: .Normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: "deleteWord", forControlEvents: .TouchUpInside)
        deleteButton.frame = CGRectMake(CGRectGetMinX(nextButton.frame) - screenWidth/8, screenHeight - screenWidth/8, screenWidth/8 - 1, screenWidth/8)
        buttonArray.append(nextButton)
        buttonArray.append(deleteButton)
        view.addSubview(deleteButton)
        view.addSubview(nextButton)
    }
    
    func addVariableKeySizeButtonWithTitle(keyTitle : String, tag : NSInteger, keyText : String, colorIndex : String) {
        let keyButton = UIButton(type: .Custom)
        keyButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        keyButton.layer.cornerRadius = 10
        keyButton.layer.borderColor = UIColor.blackColor().CGColor
        keyButton.layer.borderWidth = 0.5
        keyButton.setTitle(keyTitle, forState: .Normal)
        keyButton.addTarget(self, action: "keyPressed:", forControlEvents: .TouchUpInside)
        buttonArray.append(keyButton)
        
        switch data.count {
        case 1 :
            keyButton.frame = CGRectMake(0, 0, screenWidth, screenHeight/2)
            break
        case 2:
            keyButton.frame = CGRectMake(tag == 0 ? 0 : midScreenWidth, 0, screenWidth/2 - 2, screenHeight/2)
            break
        case 3:
            if tag == 0 {
                keyButton.frame = CGRectMake(0, 0, screenWidth/2, 200)
            }
            else if tag == 1 {
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 0, screenWidth/2 - 5, 100)
            }
            else {
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 101, screenWidth/2 - 5, 48)
            }
            break
        case 4:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth * 2/3 - 1, 100)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth * 2/3, 0, screenWidth/3 - 1, 100)
                break
            case 2:
                keyButton.frame = CGRectMake(0, 101, screenWidth/2 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 101, screenWidth/2 - 1, 58)
                break
            default: keyButton.frame = CGRectZero
            }
        case 5:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth * 2/3 - 1, 100)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth * 2/3, 0, screenWidth/3 - 1, 100)
                break
            case 2:
                keyButton.frame = CGRectMake(0, 101, screenWidth/3 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(screenWidth/3 - 1, 101, screenWidth/3 - 1, 100)
                break
            case 4:
                keyButton.frame = CGRectMake((screenWidth * 2/3) - 1, 101, screenWidth/3 - 1, 58)
                break
            default:
                keyButton.frame = CGRectZero
            }
        case 6:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth * 2/3 - 1, 110)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth * 2/3, 0, screenWidth/3 - 1, 110)
                break
            case 2:
                keyButton.frame = CGRectMake(0, 111, screenWidth/4 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(screenWidth/4 - 1, 111, screenWidth/4 - 1, 100)
                break
            case 4:
                keyButton.frame = CGRectMake(screenWidth/2 - 1, 111, screenWidth/4 - 1, 100)
                break
            case 5:
                keyButton.frame = CGRectMake((screenWidth * 3/4) + 1, 111, screenWidth/4 - 1, 58)
                break
            default:
                keyButton.frame = CGRectZero
            }
        case 7:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth/2 - 1, 100)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth/2, 0, screenWidth/4 - 1, 100)
                break
            case 2:
                keyButton.frame = CGRectMake(screenWidth * 3/4, 0, screenWidth/4 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(0, 101, screenWidth/4 - 1, 100)
                break
            case 4:
                keyButton.frame = CGRectMake(screenWidth/4 - 1, 101, screenWidth/4 - 1, 100)
                break
            case 5:
                keyButton.frame = CGRectMake(screenWidth/2 - 1, 101, screenWidth/4 - 1, 100)
                break
            case 6:
                keyButton.frame = CGRectMake((screenWidth * 3/4) + 1, 101, screenWidth/4 - 1, 58)
                break
            default:
                keyButton.frame = CGRectZero
            }
        
        case 8:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth/2 - 1, 100)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth/2, 0, screenWidth/4 - 1, 100)
                break
            case 2:
                keyButton.frame = CGRectMake(screenWidth * 3/4, 0, screenWidth/4 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(0, 101, screenWidth/4 - 1, 67)
                break
            case 4:
                keyButton.frame = CGRectMake(screenWidth/4 + 1, 101, screenWidth/4 - 1, 67)
                break
            case 5:
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 101, screenWidth/4 - 1, 67)
                break
            case 6:
                keyButton.frame = CGRectMake((screenWidth * 3/4) + 1, 101, screenWidth/4 - 1, 67)
                break
            case 7:
                keyButton.frame = CGRectMake(0, 169, screenWidth * 3/4 - 1, 47)
            default:
                keyButton.frame = CGRectZero
            }
            
        case 9:
            switch tag {
            case 0:
                keyButton.frame = CGRectMake(0, 0, screenWidth/2 - 1, 100)
                break
            case 1:
                keyButton.frame = CGRectMake(screenWidth/2, 0, screenWidth/4 - 1, 100)
                break
            case 2:
                keyButton.frame = CGRectMake(screenWidth * 3/4, 0, screenWidth/4 - 1, 100)
                break
            case 3:
                keyButton.frame = CGRectMake(0, 101, screenWidth/4 - 1, 67)
                break
            case 4:
                keyButton.frame = CGRectMake(screenWidth/4 + 1, 101, screenWidth/4 - 1, 67)
                break
            case 5:
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 101, screenWidth/4 - 1, 67)
                break
            case 6:
                keyButton.frame = CGRectMake((screenWidth * 3/4) + 1, 101, screenWidth/4 - 1, 67)
                break
            case 7:
                keyButton.frame = CGRectMake(0, 169, screenWidth/2, 48)
                break
            case 8:
                keyButton.frame = CGRectMake(screenWidth/2 + 1, 169, screenWidth/4 - 1, 46)
                break
            default:
                keyButton.frame = CGRectZero
            }
            
            default: keyButton.frame = CGRectZero
        }
        
        view.addSubview(keyButton)
    }
    
    func keyPressed (button: UIButton) {
        let originalColor = button.backgroundColor
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            button.backgroundColor = UIColor.lightGrayColor()
        }) { (value) in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                button.backgroundColor = originalColor
            })
        }
        let text = button.titleForState(.Disabled)
        let proxy = textDocumentProxy 
        proxy.insertText(text!)
    }
    
    func deleteWord () {
        let proxy = textDocumentProxy 
        proxy.deleteBackward()
        let tokens = proxy.documentContextBeforeInput!.componentsSeparatedByString(" ")
        for var index = 0; index  < tokens.last!.utf16.count; index++ {
            proxy.deleteBackward()
        }
    }

    override func textWillChange(textInput: UITextInput?) {
        
    }

    override func textDidChange(textInput: UITextInput?) {
    }
}

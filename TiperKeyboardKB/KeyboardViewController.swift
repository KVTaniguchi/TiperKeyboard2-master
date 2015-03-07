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

    @IBOutlet var nextKeyboardButton: UIButton!
    
    let defaultskey = "tiper2Keyboard"
    var dataArray = [[String:String]]()
    var buttonArray = [UIButton]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.InfoKeyboard")
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.sharedDefaults?.objectForKey(defaultskey) != nil {
            self.dataArray = self.sharedDefaults?.objectForKey(defaultskey) as! [[String:String]]
        }
        
        for (index, entry) in enumerate(self.dataArray) {
            for (key, value) in entry {
                addKeyboardButton(key, tag: index, keyTitle: value)
            }
        }
    
        self.nextKeyboardButton = UIButton.buttonWithType(.System) as! UIButton
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.nextKeyboardButton)

        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
    }
    
    func addKeyboardButton (keyText: String, tag: NSInteger, keyTitle: String) {
        let keyboardButton = KeyButton.buttonWithType(.Custom) as! KeyButton
        keyboardButton.setTitle(keyTitle, forState: .Normal)
        keyboardButton.keyText = keyText
        keyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        keyboardButton.addTarget(self, action: "keyPressed:", forControlEvents: .TouchUpInside)
        keyboardButton.backgroundColor = getRandomColor()
        self.view.addSubview(keyboardButton)
        
        var keyboardTopConstraint = NSLayoutConstraint()
        if tag == 0 || tag == 5 {
            keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        }
        else if tag > 0 && tag < 10 {
            let previousButton = self.buttonArray[tag - 1] as UIButton
            keyboardTopConstraint = NSLayoutConstraint(item: keyboardButton, attribute: .Top, relatedBy: .Equal, toItem: previousButton, attribute: .Bottom, multiplier: 1.0, constant: 0)
        }
        
        var keyboardWidth = NSLayoutConstraint(item: keyboardButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.5, constant: 0)
        
        var sideAttribute : NSLayoutAttribute?
        if tag <= 4 {
            sideAttribute = NSLayoutAttribute.Left
        }
        else if tag >= 5 {
            sideAttribute = NSLayoutAttribute.Right
        }
        var keyboardSideConstraint = NSLayoutConstraint(item: keyboardButton, attribute: sideAttribute!, relatedBy: .Equal, toItem: self.view, attribute: sideAttribute! , multiplier: 1.0, constant: 0)
        var keyboardHeight = NSLayoutConstraint(item: keyboardButton, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.2, constant: 0)
        
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
        print("will change text")
    }

    override func textDidChange(textInput: UITextInput) {
        var textColor: UIColor
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }
    
    func getRandomColor() -> UIColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
